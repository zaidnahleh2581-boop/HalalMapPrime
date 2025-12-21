
//
//  FirebaseAdsService.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2025-12-17.
//  Updated by Zaid Nahleh on 2025-12-21.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//
//  NOTE:
//  This service is for "community/classified ads" (light ads).
//  It uses a separate collection to avoid conflict with AdsStore ("ads").
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Ad Model (lightweight)
struct HMPAd: Identifiable, Equatable {
    let id: String
    let ownerId: String

    let title: String
    let details: String
    let phone: String

    let category: String
    let city: String

    let createdAt: Date
    let isActive: Bool
    let expiresAt: Date?

    static func from(doc: DocumentSnapshot) -> HMPAd? {
        let data = doc.data() ?? [:]

        guard
            let ownerId = data["ownerId"] as? String,
            let title = data["title"] as? String,
            let details = data["details"] as? String,
            let phone = data["phone"] as? String,
            let category = data["category"] as? String,
            let city = data["city"] as? String,
            let isActive = data["isActive"] as? Bool
        else { return nil }

        let createdAtTS = data["createdAt"] as? Timestamp
        let expiresAtTS = data["expiresAt"] as? Timestamp

        return HMPAd(
            id: doc.documentID,
            ownerId: ownerId,
            title: title,
            details: details,
            phone: phone,
            category: category,
            city: city,
            createdAt: createdAtTS?.dateValue() ?? Date(),
            isActive: isActive,
            expiresAt: expiresAtTS?.dateValue()
        )
    }

    func toFirestore() -> [String: Any] {
        var dict: [String: Any] = [
            "ownerId": ownerId,
            "title": title,
            "details": details,
            "phone": phone,
            "category": category,
            "city": city,
            "createdAt": Timestamp(date: createdAt),
            "isActive": isActive
        ]

        if let expiresAt {
            dict["expiresAt"] = Timestamp(date: expiresAt)
        }
        return dict
    }
}

// MARK: - Firebase Ads Service
final class FirebaseAdsService {

    static let shared = FirebaseAdsService()
    private init() {}

    private let db = Firestore.firestore()

    // ✅ مهم: لا تستخدم "ads" حتى لا تتعارض مع AdsStore
    private let adsCollection = "community_ads"

    // MARK: Create (Save) Ad
    func createAd(
        title: String,
        details: String,
        phone: String,
        category: String,
        city: String,
        expiresAt: Date? = nil
    ) async throws -> String {

        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "FirebaseAdsService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in."]
            )
        }

        let docRef = db.collection(adsCollection).document()

        let ad = HMPAd(
            id: docRef.documentID,
            ownerId: uid,
            title: title,
            details: details,
            phone: phone,
            category: category,
            city: city,
            createdAt: Date(),
            isActive: true,
            expiresAt: expiresAt
        )

        try await docRef.setData(ad.toFirestore(), merge: false)
        return docRef.documentID
    }

    // MARK: Listener - Active Ads (Real-time)
    func listenActiveAds(onChange: @escaping ([HMPAd]) -> Void) -> ListenerRegistration {

        let query = db.collection(adsCollection)
            .whereField("isActive", isEqualTo: true)
            .order(by: "createdAt", descending: true)

        return query.addSnapshotListener { snapshot, error in
            guard error == nil, let docs = snapshot?.documents else {
                onChange([])
                return
            }
            let ads = docs.compactMap { HMPAd.from(doc: $0) }
            onChange(ads)
        }
    }

    // MARK: Listener - My Ads (Real-time)
    func listenMyAds(ownerId: String, onChange: @escaping ([HMPAd]) -> Void) -> ListenerRegistration {

        let query = db.collection(adsCollection)
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)

        return query.addSnapshotListener { snapshot, error in
            guard error == nil, let docs = snapshot?.documents else {
                onChange([])
                return
            }
            let ads = docs.compactMap { HMPAd.from(doc: $0) }
            onChange(ads)
        }
    }

    // MARK: Hard Delete
    func deleteAd(adId: String) async throws {
        try await db.collection(adsCollection).document(adId).delete()
    }

    // MARK: Soft Delete (hide from active)
    func deactivateAd(adId: String) async throws {
        try await db.collection(adsCollection).document(adId).updateData([
            "isActive": false
        ])
    }
}

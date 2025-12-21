//
//  FirebaseAdsService.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/17/25.
//  Updated by Zaid Nahleh on 12/21/25
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// ✅ Renamed to avoid conflicts with AdsStore/FirebaseAd
struct HMPMarketplaceAd: Identifiable, Equatable {
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

    static func from(doc: DocumentSnapshot) -> HMPMarketplaceAd? {
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

        return HMPMarketplaceAd(
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

// ✅ Renamed to avoid duplicate class name in project
final class HMPMarketplaceAdsService {

    static let shared = HMPMarketplaceAdsService()
    private init() {}

    private let db = Firestore.firestore()
    private let adsCollection = "ads"

    func createAd(
        title: String,
        details: String,
        phone: String,
        category: String,
        city: String,
        expiresAt: Date? = nil
    ) async throws -> String {

        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "HMPMarketplaceAdsService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "User not logged in."
            ])
        }

        let docRef = db.collection(adsCollection).document()

        let ad = HMPMarketplaceAd(
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

    func listenActiveAds(onChange: @escaping ([HMPMarketplaceAd]) -> Void) -> ListenerRegistration {
        let query = db.collection(adsCollection)
            .whereField("isActive", isEqualTo: true)
            .order(by: "createdAt", descending: true)

        return query.addSnapshotListener { snapshot, error in
            guard error == nil, let docs = snapshot?.documents else {
                onChange([])
                return
            }
            let ads = docs.compactMap { HMPMarketplaceAd.from(doc: $0) }
            onChange(ads)
        }
    }

    func listenMyAds(ownerId: String, onChange: @escaping ([HMPMarketplaceAd]) -> Void) -> ListenerRegistration {
        let query = db.collection(adsCollection)
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)

        return query.addSnapshotListener { snapshot, error in
            guard error == nil, let docs = snapshot?.documents else {
                onChange([])
                return
            }
            let ads = docs.compactMap { HMPMarketplaceAd.from(doc: $0) }
            onChange(ads)
        }
    }

    func deleteAd(adId: String) async throws {
        try await db.collection(adsCollection).document(adId).delete()
    }

    func deactivateAd(adId: String) async throws {
        try await db.collection(adsCollection).document(adId).updateData([
            "isActive": false
        ])
    }
}

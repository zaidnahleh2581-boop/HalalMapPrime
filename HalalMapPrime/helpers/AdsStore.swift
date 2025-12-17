//
//  AdsStore.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//  Updated by Zaid Nahleh on 12/17/25.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

struct FirebaseAd: Identifiable, Equatable {
    let id: String
    let ownerId: String

    let tier: String
    let status: String

    let businessName: String
    let ownerName: String
    let phone: String
    let addressLine: String
    let city: String
    let state: String

    let businessType: String
    let template: String

    let placeId: String?
    let imageURLs: [String]

    let createdAt: Date
    let expiresAt: Date?
    let isActive: Bool

    static func from(doc: DocumentSnapshot) -> FirebaseAd? {
        let data = doc.data() ?? [:]

        func str(_ key: String) -> String { data[key] as? String ?? "" }
        func bool(_ key: String) -> Bool { data[key] as? Bool ?? false }
        func tsDate(_ key: String) -> Date? { (data[key] as? Timestamp)?.dateValue() }

        let ownerId = str("ownerId")
        if ownerId.isEmpty { return nil }

        let imageURLs = data["imageURLs"] as? [String] ?? []
        let placeId = (data["placeId"] as? String).flatMap { $0.isEmpty ? nil : $0 }

        return FirebaseAd(
            id: doc.documentID,
            ownerId: ownerId,
            tier: str("tier"),
            status: str("status"),
            businessName: str("businessName"),
            ownerName: str("ownerName"),
            phone: str("phone"),
            addressLine: str("addressLine"),
            city: str("city"),
            state: str("state"),
            businessType: str("businessType"),
            template: str("template"),
            placeId: placeId,
            imageURLs: imageURLs,
            createdAt: tsDate("createdAt") ?? Date(),
            expiresAt: tsDate("expiresAt"),
            isActive: bool("isActive")
        )
    }
}

final class AdsStore: ObservableObject {

    static let shared = AdsStore()
    private init() {}

    @Published private(set) var activeAds: [FirebaseAd] = []
    @Published private(set) var myAds: [FirebaseAd] = []

    private let db = Firestore.firestore()
    private let adsCollection = "ads"

    private var activeListener: ListenerRegistration?
    private var myListener: ListenerRegistration?

    func startActiveListener() {
        activeListener?.remove()

        let query = db.collection(adsCollection)
            .whereField("isActive", isEqualTo: true)
            .order(by: "createdAt", descending: true)

        activeListener = query.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }
            guard err == nil, let docs = snap?.documents else {
                DispatchQueue.main.async { self.activeAds = [] }
                return
            }
            let ads = docs.compactMap { FirebaseAd.from(doc: $0) }
            DispatchQueue.main.async { self.activeAds = ads }
        }
    }

    func startMyAdsListener() {
        myListener?.remove()

        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async { self.myAds = [] }
            return
        }

        let query = db.collection(adsCollection)
            .whereField("ownerId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)

        myListener = query.addSnapshotListener { [weak self] snap, err in
            guard let self else { return }
            guard err == nil, let docs = snap?.documents else {
                DispatchQueue.main.async { self.myAds = [] }
                return
            }
            let ads = docs.compactMap { FirebaseAd.from(doc: $0) }
            DispatchQueue.main.async { self.myAds = ads }
        }
    }

    func stopAllListeners() {
        activeListener?.remove()
        myListener?.remove()
        activeListener = nil
        myListener = nil
    }

    func deleteAd(adId: String) async throws {
        try await db.collection(adsCollection).document(adId).delete()
    }
}

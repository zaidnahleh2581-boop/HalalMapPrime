//
//  EventAdsService.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum MonthlyGateError: LocalizedError {
    case limitReached(nextAllowedDate: Date)

    var errorDescription: String? {
        switch self {
        case .limitReached(let next):
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            return "You already used your free monthly post. Next free date: \(df.string(from: next))"
        }
    }
}

struct EventAd: Identifiable {
    let id: String
    let ownerId: String
    let title: String
    let city: String
    let placeName: String
    let date: Date
    let description: String
    let phone: String
    let templateId: String

    let tier: String            // "free" / "paid"
    let priceCents: Int
    let paidAt: Date?
    let paymentRef: String?

    let createdAt: Date
    let updatedAt: Date?
    let deletedAt: Date?

    init?(snapshot: DocumentSnapshot) {
        let data = snapshot.data() ?? [:]

        guard
            let ownerId = data["ownerId"] as? String,
            let title = data["title"] as? String,
            let city = data["city"] as? String,
            let placeName = data["placeName"] as? String,
            let description = data["description"] as? String,
            let phone = data["phone"] as? String,
            let dateTS = data["date"] as? Timestamp
        else { return nil }

        self.id = snapshot.documentID
        self.ownerId = ownerId
        self.title = title
        self.city = city
        self.placeName = placeName
        self.description = description
        self.phone = phone
        self.date = dateTS.dateValue()

        self.templateId = data["templateId"] as? String ?? "communityMeeting"

        self.tier = data["tier"] as? String ?? "free"
        self.priceCents = data["priceCents"] as? Int ?? 0

        if let ts = data["paidAt"] as? Timestamp { self.paidAt = ts.dateValue() } else { self.paidAt = nil }
        self.paymentRef = data["paymentRef"] as? String

        if let createdTS = data["createdAt"] as? Timestamp { self.createdAt = createdTS.dateValue() } else { self.createdAt = Date() }
        if let ts = data["updatedAt"] as? Timestamp { self.updatedAt = ts.dateValue() } else { self.updatedAt = nil }
        if let ts = data["deletedAt"] as? Timestamp { self.deletedAt = ts.dateValue() } else { self.deletedAt = nil }
    }
}

final class EventAdsService {

    static let shared = EventAdsService()

    private let db = Firestore.firestore()
    private let collectionName = "cityEventAds"
    private let usersCollection = "users"

    private init() {}

    // MARK: - Auth Helper (Anonymous)

    private func ensureSignedIn(completion: @escaping (Result<String, Error>) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            completion(.success(uid))
            return
        }

        Auth.auth().signInAnonymously { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let uid = result?.user.uid else {
                completion(.failure(NSError(
                    domain: "Auth",
                    code: 500,
                    userInfo: [NSLocalizedDescriptionKey: "Anonymous sign-in returned no uid"]
                )))
                return
            }
            completion(.success(uid))
        }
    }

    // MARK: - Monthly Gate (consume even if deleted)

    private func userDocRef(uid: String) -> DocumentReference {
        db.collection(usersCollection).document(uid)
    }

    private func canPostFreeThisMonth(lastPost: Date?, now: Date = Date()) -> (allowed: Bool, nextAllowed: Date?) {
        guard let lastPost else { return (true, nil) }
        let next = Calendar.current.date(byAdding: .day, value: 30, to: lastPost)
        ?? lastPost.addingTimeInterval(30 * 24 * 60 * 60)
        return (now >= next, next)
    }

    private func fetchLastFreePostDate(uid: String, completion: @escaping (Result<Date?, Error>) -> Void) {
        userDocRef(uid: uid).getDocument { snap, error in
            if let error { completion(.failure(error)); return }
            guard let data = snap?.data() else { completion(.success(nil)); return }
            if let ts = data["lastFreeEventPostAt"] as? Timestamp {
                completion(.success(ts.dateValue()))
            } else {
                completion(.success(nil))
            }
        }
    }

    // MARK: - Observe Upcoming Events (all users)

    @discardableResult
    func observeUpcomingEvents(
        completion: @escaping (Result<[EventAd], Error>) -> Void
    ) -> ListenerRegistration {

        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayTS = Timestamp(date: todayStart)

        return db.collection(collectionName)
            .whereField("deletedAt", isEqualTo: NSNull())
            .whereField("date", isGreaterThanOrEqualTo: todayTS)
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let docs = snapshot?.documents ?? []
                let events = docs.compactMap { EventAd(snapshot: $0) }
                completion(.success(events))
            }
    }

    // MARK: - Observe My Events (owner only) ✅ NO DeferredListener / NO duplicates

    @discardableResult
    func observeMyEvents(
        completion: @escaping (Result<[EventAd], Error>) -> Void
    ) -> ListenerRegistration {

        // ✅ Placeholder listener (valid ListenerRegistration we can return immediately)
        let placeholder = db.collection(collectionName)
            .limit(to: 1)
            .addSnapshotListener { _, _ in }

        ensureSignedIn { [weak self] authResult in
            guard let self else { return }

            switch authResult {
            case .failure(let error):
                completion(.failure(error))

            case .success(let uid):
                // stop placeholder ASAP
                placeholder.remove()

                self.db.collection(self.collectionName)
                    .whereField("ownerId", isEqualTo: uid)
                    .whereField("deletedAt", isEqualTo: NSNull())
                    .order(by: "createdAt", descending: true)
                    .addSnapshotListener { snapshot, error in
                        if let error {
                            completion(.failure(error))
                            return
                        }

                        let docs = snapshot?.documents ?? []
                        let items = docs.compactMap { EventAd(snapshot: $0) }
                        completion(.success(items))
                    }
            }
        }

        return placeholder
    }

    // MARK: - Gate Check (free)

    func canCreateFreeEventThisMonth(completion: @escaping (Result<Bool, Error>) -> Void) {
        ensureSignedIn { [weak self] authResult in
            guard let self else { return }

            switch authResult {
            case .failure(let error):
                completion(.failure(error))

            case .success(let uid):
                self.fetchLastFreePostDate(uid: uid) { gateResult in
                    switch gateResult {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let lastDate):
                        let gate = self.canPostFreeThisMonth(lastPost: lastDate)
                        completion(.success(gate.allowed))
                    }
                }
            }
        }
    }

    // MARK: - Create FREE

    func createEventAd(
        title: String,
        city: String,
        placeName: String,
        date: Date,
        description: String,
        phone: String,
        templateId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        ensureSignedIn { [weak self] authResult in
            guard let self else { return }

            switch authResult {
            case .failure(let error):
                completion(.failure(error))

            case .success(let uid):
                self.fetchLastFreePostDate(uid: uid) { gateResult in
                    switch gateResult {
                    case .failure(let error):
                        completion(.failure(error))

                    case .success(let lastDate):
                        let gate = self.canPostFreeThisMonth(lastPost: lastDate)
                        guard gate.allowed else {
                            completion(.failure(MonthlyGateError.limitReached(nextAllowedDate: gate.nextAllowed ?? Date())))
                            return
                        }

                        let eventRef = self.db.collection(self.collectionName).document()
                        let userRef = self.userDocRef(uid: uid)
                        let batch = self.db.batch()

                        let eventData: [String: Any] = [
                            "ownerId": uid,
                            "title": title,
                            "city": city,
                            "placeName": placeName,
                            "date": Timestamp(date: date),
                            "description": description,
                            "phone": phone,
                            "templateId": templateId,

                            "tier": "free",
                            "priceCents": 0,
                            "paidAt": NSNull(),
                            "paymentRef": NSNull(),

                            "deletedAt": NSNull(),
                            "updatedAt": NSNull(),
                            "createdAt": FieldValue.serverTimestamp()
                        ]

                        batch.setData(eventData, forDocument: eventRef)
                        batch.setData(["lastFreeEventPostAt": FieldValue.serverTimestamp()],
                                      forDocument: userRef,
                                      merge: true)

                        batch.commit { error in
                            if let error { completion(.failure(error)) }
                            else { completion(.success(())) }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Create PAID (after IAP)

    func createPaidEventAd(
        title: String,
        city: String,
        placeName: String,
        date: Date,
        description: String,
        phone: String,
        templateId: String,
        priceCents: Int,
        paymentRef: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        ensureSignedIn { [weak self] authResult in
            guard let self else { return }

            switch authResult {
            case .failure(let error):
                completion(.failure(error))

            case .success(let uid):
                let eventRef = self.db.collection(self.collectionName).document()

                let eventData: [String: Any] = [
                    "ownerId": uid,
                    "title": title,
                    "city": city,
                    "placeName": placeName,
                    "date": Timestamp(date: date),
                    "description": description,
                    "phone": phone,
                    "templateId": templateId,

                    "tier": "paid",
                    "priceCents": priceCents,
                    "paidAt": FieldValue.serverTimestamp(),
                    "paymentRef": paymentRef,

                    "deletedAt": NSNull(),
                    "updatedAt": NSNull(),
                    "createdAt": FieldValue.serverTimestamp()
                ]

                eventRef.setData(eventData) { error in
                    if let error { completion(.failure(error)) }
                    else { completion(.success(())) }
                }
            }
        }
    }

    // MARK: - Update

    func updateEventAd(
        adId: String,
        ownerId: String,
        title: String,
        city: String,
        placeName: String,
        date: Date,
        description: String,
        phone: String,
        templateId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        ensureSignedIn { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let uid):
                guard uid == ownerId else {
                    completion(.failure(NSError(
                        domain: "Auth",
                        code: 403,
                        userInfo: [NSLocalizedDescriptionKey: "Not allowed: you are not the owner of this event."]
                    )))
                    return
                }

                let data: [String: Any] = [
                    "title": title,
                    "city": city,
                    "placeName": placeName,
                    "date": Timestamp(date: date),
                    "description": description,
                    "phone": phone,
                    "templateId": templateId,
                    "updatedAt": FieldValue.serverTimestamp()
                ]

                self.db.collection(self.collectionName).document(adId).updateData(data) { error in
                    if let error { completion(.failure(error)) }
                    else { completion(.success(())) }
                }
            }
        }
    }

    // MARK: - Soft Delete

    func softDeleteEventAd(
        adId: String,
        ownerId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        ensureSignedIn { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let uid):
                guard uid == ownerId else {
                    completion(.failure(NSError(
                        domain: "Auth",
                        code: 403,
                        userInfo: [NSLocalizedDescriptionKey: "Not allowed: you are not the owner of this event."]
                    )))
                    return
                }

                self.db.collection(self.collectionName).document(adId).updateData([
                    "deletedAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error { completion(.failure(error)) }
                    else { completion(.success(())) }
                }
            }
        }
    }
}

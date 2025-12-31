//
//  MyPlacesStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class MyPlacesStore: ObservableObject {

    struct MyPlaceRow: Identifiable {
        let id: String
        let placeName: String
        let placeType: String
        let status: String
        let city: String
        let state: String
        let createdAt: Date?
    }

    @Published var items: [MyPlaceRow] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    deinit { listener?.remove() }

    // ✅ Ensure UID (anonymous if needed)
    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }

        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<String, Error>) in
            Auth.auth().signInAnonymously { result, error in
                if let error { cont.resume(throwing: error); return }
                guard let uid = result?.user.uid else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1,
                                                  userInfo: [NSLocalizedDescriptionKey: "Missing UID"]))
                    return
                }
                cont.resume(returning: uid)
            }
        }
    }

    func startListeningMyPlaces() {
        Task {
            do {
                isLoading = true
                errorMessage = nil

                let uid = try await ensureUID()

                listener?.remove()
                listener = db.collection("place_submissions")
                    .whereField("ownerId", isEqualTo: uid)
                    .order(by: "createdAt", descending: true)
                    .addSnapshotListener { [weak self] snap, err in
                        guard let self else { return }

                        if let err {
                            self.errorMessage = err.localizedDescription
                            self.isLoading = false
                            return
                        }

                        let docs = snap?.documents ?? []
                        self.items = docs.map { doc in
                            let d = doc.data()

                            let name = (d["placeName"] as? String) ?? "Untitled"
                            let type = (d["placeType"] as? String) ?? "-"
                            let status = (d["status"] as? String) ?? "pending"
                            let city = (d["city"] as? String) ?? ""
                            let state = (d["state"] as? String) ?? ""
                            let createdAt = (d["createdAt"] as? Timestamp)?.dateValue()

                            return MyPlaceRow(
                                id: doc.documentID,
                                placeName: name,
                                placeType: type,
                                status: status,
                                city: city,
                                state: state,
                                createdAt: createdAt
                            )
                        }

                        self.isLoading = false
                    }

            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func deletePlace(docId: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            db.collection("place_submissions").document(docId).delete { error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }
}

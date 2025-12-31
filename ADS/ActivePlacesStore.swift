//
//  ActivePlacesStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore
import MapKit

@MainActor
final class ActivePlacesStore: ObservableObject {

    // MARK: - Model
    struct ActivePlace: Identifiable {
        let id: String
        let name: String
        let type: String
        let city: String
        let state: String
        let coordinate: CLLocationCoordinate2D
    }

    // MARK: - Published
    @Published var places: [ActivePlace] = []
    @Published var errorMessage: String? = nil

    // MARK: - Private
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Public API
    func startListening() {
        listener?.remove()

        listener = db.collection("place_submissions")
            .whereField("status", isEqualTo: "active")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let docs = snapshot?.documents else {
                    self.places = []
                    return
                }

                self.places = docs.compactMap { doc in
                    let data = doc.data()

                    guard
                        let name = data["placeName"] as? String,
                        let type = data["placeType"] as? String,
                        let city = data["city"] as? String,
                        let state = data["state"] as? String,
                        let lat = data["lat"] as? Double,
                        let lng = data["lng"] as? Double
                    else {
                        return nil
                    }

                    return ActivePlace(
                        id: doc.documentID,
                        name: name,
                        type: type,
                        city: city,
                        state: state,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    )
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}

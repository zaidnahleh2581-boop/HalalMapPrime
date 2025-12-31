//
//  PlaceSubmissionsStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import MapKit
import CoreLocation

@MainActor
final class PlaceSubmissionsStore: ObservableObject {

    static let shared = PlaceSubmissionsStore()

    @Published var isSubmitting: Bool = false
    @Published var lastError: String? = nil

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Public API

    /// Submit a halal place (saved as pending by default) and stores geo automatically from address.
    func submitPlace(
        placeName: String,
        phone: String?,
        placeType: String,
        city: String,
        state: String,
        addressLine: String?,
        foodTruckStop: String?
    ) async throws -> String {

        lastError = nil
        isSubmitting = true
        defer { isSubmitting = false }

        let uid = try await ensureUID()

        // ✅ Build full address for geocoding
        let fullAddress = buildFullAddress(
            addressLine: addressLine,
            city: city,
            state: state
        )

        // ✅ Try to get coordinates (MapKit geocode style)
        let coordinate = try await geocodeAddress(fullAddress)

        var data: [String: Any] = [
            "ownerId": uid,
            "placeName": placeName,
            "placeType": placeType,
            "city": city,
            "state": state,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),

            // ✅ Save GeoPoint (THIS is what your map needs)
            "geo": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        ]

        if let phone, !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            data["phone"] = phone
        }
        if let addressLine, !addressLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            data["addressLine"] = addressLine
        }
        if let foodTruckStop, !foodTruckStop.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            data["foodTruckStop"] = foodTruckStop
        }

        let ref = try await db.collection("place_submissions").addDocument(data: data)
        return ref.documentID
    }

    // MARK: - Auth

    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }

        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error { cont.resume(throwing: error); return }
                guard let uid = result?.user.uid else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing UID"]))
                    return
                }
                cont.resume(returning: uid)
            }
        }
    }

    // MARK: - Helpers

    private func buildFullAddress(addressLine: String?, city: String, state: String) -> String {
        let a = (addressLine ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if a.isEmpty {
            // still geocode city + state (best effort)
            return "\(city), \(state)"
        }
        return "\(a), \(city), \(state)"
    }

    /// Geocoding using MapKit (safe path for modern iOS).
    private func geocodeAddress(_ address: String) async throws -> CLLocationCoordinate2D {

        // Use MKLocalSearch as “MapKit geocode” approach:
        // It finds the best match for an address string.
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address

        let search = MKLocalSearch(request: request)

        return try await withCheckedThrowingContinuation { cont in
            search.start { response, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                guard let item = response?.mapItems.first,
                      let coord = item.placemark.location?.coordinate
                else {
                    cont.resume(throwing: NSError(domain: "Geocode", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "Could not geocode address: \(address)"
                    ]))
                    return
                }
                cont.resume(returning: coord)
            }
        }
    }
}

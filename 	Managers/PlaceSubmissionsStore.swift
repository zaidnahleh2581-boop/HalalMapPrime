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

    // MARK: - Submit Place

    /// Submit a place (pending) + saves geo automatically + marks monthly free used
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

        let fullAddress = buildFullAddress(
            addressLine: addressLine,
            city: city,
            state: state
        )

        let coordinate = try await geocodeAddress(fullAddress)

        // ✅ Free Ad timing (30 days)
        let now = Date()
        let freeEnds = Calendar.current.date(byAdding: .day, value: 30, to: now)!

        var data: [String: Any] = [
            "ownerId": uid,
            "placeName": placeName,
            "placeType": placeType,
            "city": city,
            "state": state,

            // Status
            "status": "pending",

            // Dates
            "createdAt": FieldValue.serverTimestamp(),
            "isFreeAd": true,
            "adType": "free",
            "freeStartedAt": Timestamp(date: now),
            "freeEndsAt": Timestamp(date: freeEnds),

            // Geo
            "geo": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude),
            "lat": coordinate.latitude,
            "lng": coordinate.longitude
        ]

        let p = (phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !p.isEmpty { data["phone"] = p }

        let a = (addressLine ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !a.isEmpty { data["addressLine"] = a }

        let stop = (foodTruckStop ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !stop.isEmpty { data["foodTruckStop"] = stop }

        let ref = try await db.collection("place_submissions").addDocument(data: data)

        // ✅ mark monthly free used AFTER successful submit
        try await MonthlyFreeGate.shared.markFreeUsed(phone: phone)

        return ref.documentID
    }

    // MARK: - Auth

    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }

        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                guard let uid = result?.user.uid else {
                    cont.resume(throwing: NSError(
                        domain: "Auth",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Missing UID"]
                    ))
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
            return "\(city), \(state)"
        }
        return "\(a), \(city), \(state)"
    }

    /// Geocoding using MapKit (MKLocalSearch)
    private func geocodeAddress(_ address: String) async throws -> CLLocationCoordinate2D {

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
                      let coord = item.placemark.location?.coordinate else {
                    cont.resume(throwing: NSError(
                        domain: "Geocode",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Could not geocode address: \(address)"]
                    ))
                    return
                }
                cont.resume(returning: coord)
            }
        }
    }
}

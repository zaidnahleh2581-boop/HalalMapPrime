//
//  PlaceSubmissionsStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
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

    // MARK: - Gate Mode
    enum GateMode {
        case communityMonthly(phone: String?)
        case adsLifetimeGift
        case none
    }

    enum SubmitError: LocalizedError {
        case lifetimeGiftAlreadyUsed

        var errorDescription: String? {
            switch self {
            case .lifetimeGiftAlreadyUsed:
                return "Lifetime free gift already used for this place."
            }
        }
    }

    // MARK: - Submit Place

    func submitPlace(
        placeName: String,
        phone: String?,
        placeType: String,
        city: String,
        state: String,
        addressLine: String?,
        foodTruckStop: String?,
        gateMode: GateMode = .communityMonthly(phone: nil)
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

        // ✅ Geocode first
        let coordinate = try await geocodeAddress(fullAddress)

        // ✅ Normalize address for stable identity
        let normalizedAddress = normalizeAddress(fullAddress)

        // ✅ Prepare data
        var data: [String: Any] = [
            "ownerId": uid,
            "placeName": placeName,
            "placeType": placeType,
            "city": city,
            "state": state,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp(),

            "normalizedAddress": normalizedAddress,
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

        // =========================
        // ✅ Gate logic
        // =========================

        // For Lifetime Gift: consume gate using CREATE-only (NO READ)
        if case .adsLifetimeGift = gateMode {

            let placeKey = LifetimeFreePlaceGate.shared.makePlaceKey(
                normalizedAddress: normalizedAddress,
                coordinate: coordinate
            )

            do {
                try await LifetimeFreePlaceGate.shared.consumeOrThrow(
                    placeKey: placeKey,
                    payload: [
                        "firstOwnerId": uid,
                        "placeName": placeName,
                        "normalizedAddress": normalizedAddress,
                        "lat": round(coordinate.latitude * 10_000) / 10_000,
                        "lng": round(coordinate.longitude * 10_000) / 10_000
                    ]
                )
            } catch {
                // If gate create fails (most common: already exists) -> show "gift used"
                throw SubmitError.lifetimeGiftAlreadyUsed
            }

            // save placeKey inside submission (optional, helps admin tools)
            data["lifetimePlaceKey"] = placeKey
            data["gateMode"] = "adsLifetimeGift"
        }

        // ✅ Add submission
        let ref = try await db.collection("place_submissions").addDocument(data: data)

        // ✅ Mark monthly gate AFTER successful submit (keep your existing behavior)
        switch gateMode {
        case .communityMonthly(let gatePhone):
            try await MonthlyFreeGate.shared.markFreeUsed(phone: gatePhone ?? phone)

        case .adsLifetimeGift:
            // Already consumed above — nothing else needed.
            break

        case .none:
            break
        }

        return ref.documentID
    }

    // MARK: - Auth

    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }

        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error { cont.resume(throwing: error); return }
                guard let uid = result?.user.uid else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Missing UID"
                    ]))
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

    private func normalizeAddress(_ address: String) -> String {
        let lower = address.lowercased()
        let cleaned = lower
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
        let parts = cleaned.split(whereSeparator: { $0.isWhitespace })
        return parts.joined(separator: " ")
    }

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

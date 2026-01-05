//
//  LifetimeFreePlaceGate.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import FirebaseFirestore
import CryptoKit
import MapKit

@MainActor
final class LifetimeFreePlaceGate {

    static let shared = LifetimeFreePlaceGate()
    private init() {}

    enum GateError: LocalizedError {
        case alreadyUsed
        var errorDescription: String? {
            switch self {
            case .alreadyUsed:
                return "Lifetime free gift already used for this place."
            }
        }
    }

    private let db = Firestore.firestore()
    private let collectionName = "free_lifetime_place_gate"

    /// Create a stable place key from normalized address + rounded geo.
    func makePlaceKey(normalizedAddress: String, coordinate: CLLocationCoordinate2D) -> String {
        let addr = normalizedAddress
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let lat = round(coordinate.latitude * 10_000) / 10_000
        let lng = round(coordinate.longitude * 10_000) / 10_000

        let raw = "addr:\(addr)|lat:\(lat)|lng:\(lng)"
        return sha256(raw)
    }

    /// ✅ Try to consume the gift (CREATE only). Never read.
    /// If it fails -> treat as already used.
    func consumeOrThrow(placeKey: String, payload: [String: Any]) async throws {
        var data = payload
        data["usedAt"] = FieldValue.serverTimestamp()
        data["placeKey"] = placeKey

        do {
            // merge: false => if doc exists this is an UPDATE and your Rules will block it
            try await db.collection(collectionName)
                .document(placeKey)
                .setData(data, merge: false)
        } catch {
            // Most common: "Missing or insufficient permissions" because UPDATE is blocked
            throw GateError.alreadyUsed
        }
    }

    // MARK: - Helpers

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

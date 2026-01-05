//
//  MonthlyFreeGate.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class MonthlyFreeGate {

    static let shared = MonthlyFreeGate()
    private init() {}

    private let db = Firestore.firestore()

    private func monthKey(for date: Date = Date()) -> String {
        let c = Calendar.current
        let y = c.component(.year, from: date)
        let m = c.component(.month, from: date)
        return "\(y)-\(String(format: "%02d", m))"
    }

    /// Returns true if user can use the monthly free slot.
    func canUseFreeThisMonth(phone: String?) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }

        // Prefer phone-based gate if phone exists; fallback to uid gate.
        let key = (phone?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ? "phone:\(phone!.trimmingCharacters(in: .whitespacesAndNewlines))"
        : "uid:\(uid)"

        let month = monthKey()

        let docId = "\(key)|\(month)"
        let ref = db.collection("free_monthly_gate").document(docId)

        let snap = try await ref.getDocument()
        return !snap.exists
    }

    /// Marks the monthly free slot as used (call only after successful submit).
    func markFreeUsed(phone: String?) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let key = (phone?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ? "phone:\(phone!.trimmingCharacters(in: .whitespacesAndNewlines))"
        : "uid:\(uid)"

        let month = monthKey()
        let docId = "\(key)|\(month)"

        try await db.collection("free_monthly_gate").document(docId).setData([
            "uid": uid,
            "key": key,
            "month": month,
            "usedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}

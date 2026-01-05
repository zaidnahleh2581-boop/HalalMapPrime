//
//  FreeAdStateStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class FreeAdStateStore: ObservableObject {

    enum State: Equatable {
        case loading
        case neverUsed
        case alreadyUsed
        case error(String)
    }

    @Published var state: State = .loading

    private let db = Firestore.firestore()

    func refresh() {
        Task { await refreshAsync() }
    }

    func refreshAsync() async {
        state = .loading
        do {
            let uid = try await ensureUID()
            let used = try await didUseFreeThisMonth(uid: uid)
            state = used ? .alreadyUsed : .neverUsed
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Month Key

    private func monthKey(for date: Date = Date()) -> String {
        let c = Calendar.current
        let y = c.component(.year, from: date)
        let m = c.component(.month, from: date)
        return "\(y)-\(String(format: "%02d", m))"
    }

    // MARK: - Gate Check (RULES FRIENDLY)
    // Rules: /free_monthly_gate/{uid} read/write only by that uid
    // So we MUST read document(uid) — NOT query the collection.

    private func didUseFreeThisMonth(uid: String) async throws -> Bool {
        let month = monthKey()

        let doc = try await db.collection("free_monthly_gate")
            .document(uid)
            .getDocument()

        // If doc doesn't exist -> never used
        guard doc.exists else { return false }

        let lastMonth = doc.data()?["lastFreeMonth"] as? String
        return lastMonth == month
    }

    // MARK: - Mark Used (call this after creating the free ad successfully)

    func markUsedThisMonth() async throws {
        let uid = try await ensureUID()
        let month = monthKey()

        try await db.collection("free_monthly_gate")
            .document(uid)
            .setData([
                "uid": uid,
                "lastFreeMonth": month,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
    }

    // MARK: - Auth

    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }

        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error { cont.resume(throwing: error); return }
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
}

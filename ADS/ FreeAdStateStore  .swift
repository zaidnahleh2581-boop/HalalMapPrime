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

    // MARK: - Gate Query (NO composite index needed)

    private func monthKey(for date: Date = Date()) -> String {
        let c = Calendar.current
        let y = c.component(.year, from: date)
        let m = c.component(.month, from: date)
        return "\(y)-\(String(format: "%02d", m))"
    }

    private func didUseFreeThisMonth(uid: String) async throws -> Bool {
        let month = monthKey()

        let snap = try await db.collection("free_monthly_gate")
            .whereField("uid", isEqualTo: uid)
            .whereField("month", isEqualTo: month)
            .limit(to: 1)
            .getDocuments()

        return !snap.documents.isEmpty
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

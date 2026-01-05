//
//  FreeOnceGateStore.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/4/26.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class FreeOnceGateStore {

    static let shared = FreeOnceGateStore()
    private init() {}

    private let db = Firestore.firestore()

    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { res, err in
                if let err { cont.resume(throwing: err); return }
                guard let uid = res?.user.uid else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1,
                                                  userInfo: [NSLocalizedDescriptionKey: "Missing UID"]))
                    return
                }
                cont.resume(returning: uid)
            }
        }
    }

    func canUseFreeOnce() async throws -> Bool {
        let uid = try await ensureUID()
        let doc = try await db.collection("free_once_gate").document(uid).getDocument()
        return !doc.exists
    }

    func markUsed() async throws {
        let uid = try await ensureUID()
        try await db.collection("free_once_gate").document(uid).setData([
            "uid": uid,
            "usedAt": FieldValue.serverTimestamp()
        ], merge: false)
    }
}

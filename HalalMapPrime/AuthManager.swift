//
//  AuthManager.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/17/25
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    /// ✅ Guaranteed user (anonymous) before any Firestore/Storage write
    func ensureSignedIn() async throws -> String {
        if let user = Auth.auth().currentUser {
            return user.uid
        }

        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    cont.resume(throwing: error)
                    return
                }
                if let uid = result?.user.uid {
                    cont.resume(returning: uid)
                    return
                }
                cont.resume(throwing: NSError(
                    domain: "AuthManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No user returned from signInAnonymously"]
                ))
            }
        }
    }
}

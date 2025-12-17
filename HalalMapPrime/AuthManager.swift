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

    func ensureSignedIn() {
        if let user = Auth.auth().currentUser {
            print("✅ Already signed in:", user.uid)
            return
        }

        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("❌ Anonymous sign-in failed:", error.localizedDescription)
            } else {
                print("✅ Signed in anonymously:", result?.user.uid ?? "")
            }
        }
    }
}

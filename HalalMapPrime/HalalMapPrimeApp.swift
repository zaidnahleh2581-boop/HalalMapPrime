//
//  HalalMapPrimeApp.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/17/25
//

import SwiftUI
import FirebaseCore

@main
struct HalalMapPrimeApp: App {

    @StateObject private var languageManager = LanguageManager()

    init() {
        FirebaseApp.configure()
        AuthManager.shared.ensureSignedIn()   // ✅ هذا هو الحل
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
        }
    }
}

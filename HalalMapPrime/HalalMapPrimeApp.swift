//
//  HalalMapPrimeApp.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/21/25
//

import SwiftUI
import FirebaseCore
import GoogleMaps

@main
struct HalalMapPrimeApp: App {

    @StateObject private var languageManager = LanguageManager()

    init() {
        FirebaseApp.configure()

        // ✅ Do NOT crash the app if key is missing (MapKit still works)
        if let apiKey = Bundle.main.infoDictionary?["GOOGLE_MAPS_API_KEY"] as? String,
           !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            GMSServices.provideAPIKey(apiKey)
        } else {
            print("⚠️ GOOGLE_MAPS_API_KEY missing — MapKit will still work.")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
        }
    }
}

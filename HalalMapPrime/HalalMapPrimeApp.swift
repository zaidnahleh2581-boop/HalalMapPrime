//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-27.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//
import SwiftUI
import FirebaseCore

@main
struct HalalMapPrimeApp: App {

    @StateObject private var languageManager = LanguageManager()
    @StateObject private var locationManager = AppLocationManager()
    @StateObject private var router = AppRouter()   // ✅ NEW

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
                .environmentObject(locationManager)
                .environmentObject(router)         // ✅ NEW
        }
    }
}

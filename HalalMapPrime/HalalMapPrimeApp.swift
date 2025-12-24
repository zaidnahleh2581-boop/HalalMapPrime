import SwiftUI
import FirebaseCore

@main
struct HalalMapPrimeApp: App {

    @StateObject private var languageManager = LanguageManager()
    @StateObject private var locationManager = LocationManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
                .environmentObject(locationManager)
        }
    }
}

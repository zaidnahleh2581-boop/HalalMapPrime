import SwiftUI
import FirebaseCore

@main
struct HalalMapPrimeApp: App {

    @StateObject private var languageManager = LanguageManager()
    @StateObject private var locationManager = AppLocationManager()
    @StateObject private var router = AppRouter()   // ✅ أضف هذا فقط

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(languageManager)
                .environmentObject(locationManager)
                .environmentObject(router)          // ✅ وأضف هذا فقط
        }
    }
}

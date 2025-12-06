import SwiftUI
import FirebaseCore

@main
struct HalalMapPrimeApp: App {

    // هذا الكود ينفّذ مرة واحدة عند تشغيل التطبيق
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

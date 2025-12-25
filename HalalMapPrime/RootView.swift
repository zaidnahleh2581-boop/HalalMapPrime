import SwiftUI
import CoreLocation

struct RootView: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var locationManager: AppLocationManager

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {

        // 1️⃣ Language first
        if !lang.didChooseLanguage {
            LanguageSelectionView()

        // 2️⃣ Location permission
        } else if !isLocationAuthorized {
            LocationPermissionView {
                // ✅ Request permission when user taps Continue
                locationManager.requestWhenInUseAuthorizationIfNeeded()
            }
            .onAppear {
                // ✅ Also request automatically when this screen appears
                locationManager.requestWhenInUseAuthorizationIfNeeded()
            }

        // 3️⃣ Main app
        } else {
            MainTabView()
                .onAppear {
                    // ✅ Make sure we attempt to fetch a location once authorized
                    locationManager.requestSingleLocationIfPossible()
                }
        }
    }

    private var isLocationAuthorized: Bool {
        let s = locationManager.authorizationStatus
        return s == .authorizedWhenInUse || s == .authorizedAlways
    }
}

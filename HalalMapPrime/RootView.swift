//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-27.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//
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
                locationManager.requestWhenInUseAuthorizationIfNeeded()
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorizationIfNeeded()
            }

        // 3️⃣ Main app
        } else {
            MainTabView()
                .onAppear {
                    locationManager.requestSingleLocationIfPossible()
                }
        }
    }

    private var isLocationAuthorized: Bool {
        let s = locationManager.authorizationStatus
        return s == .authorizedWhenInUse || s == .authorizedAlways
    }
}

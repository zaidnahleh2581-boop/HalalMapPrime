import SwiftUI

struct RootView: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var location: LocationManager

    var body: some View {
        Group {
            if !lang.didChooseLanguage {
                LanguageSelectionView()
            } else if !location.isAuthorized {
                LocationPermissionView()
            } else {
                MainTabView()
            }
        }
    }
}

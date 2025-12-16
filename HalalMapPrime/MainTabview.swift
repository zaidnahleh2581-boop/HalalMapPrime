import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var lang: LanguageManager

    var body: some View {
        TabView {

            // ✅ Home (Yelp ads feed)
            MapScreen()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "الرئيسية" : "Home", systemImage: "house.fill")
                }

            // ✅ Ads
            AdsHomeView()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "الإعلانات" : "Ads", systemImage: "megaphone.fill")
                }

            // ✅ Community (الوظائف + الفعاليات + اللوحة + إضافة مكان)
            CommunityHubScreen()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "المجتمع" : "Community", systemImage: "person.3.fill")
                }

            // ✅ Faith (الصلاة/الدين)
            FaithToolsScreen()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "العبادة" : "Faith", systemImage: "moon.stars.fill")
                }
        }
    }
}

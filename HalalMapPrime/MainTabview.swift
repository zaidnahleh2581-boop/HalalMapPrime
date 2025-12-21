//
//  MainTabview.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var lang: LanguageManager
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // 0) Home (Yelp style ads feed + search)
            MapScreen()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "هوم" : "Home", systemImage: "house.fill")
                }
                .tag(0)

            // 1) Map (Real map)
            ExploreMapScreen()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "خريطة" : "Map", systemImage: "map.fill")
                }
                .tag(1)

            // 2) Faith
            FaithToolsScreen()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "الدين" : "Faith", systemImage: "sparkles")
                }
                .tag(2)

            // 3) Community
            CommunityHubScreen()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "المجتمع" : "Community", systemImage: "person.3.fill")
                }
                .tag(3)

            // 4) Paid Ads
            AdsHomeView()
                .environmentObject(lang)
                .tabItem {
                    Label(lang.isArabic ? "إعلانات" : "Ads", systemImage: "megaphone.fill")
                }
                .tag(4)
        }
        .tint(tabTintColor())
    }

    private func tabTintColor() -> Color {
        switch selectedTab {
        case 0: return Color(red: 0.00, green: 0.55, blue: 0.50)
        case 1: return Color(red: 0.00, green: 0.55, blue: 0.50)
        case 2: return .orange
        case 3: return .teal
        case 4: return .purple
        default: return .accentColor
        }
    }
}

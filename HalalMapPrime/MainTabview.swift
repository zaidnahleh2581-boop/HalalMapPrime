//
//  MainTabView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-27.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var router: AppRouter

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        TabView(selection: $router.selectedTab) {

            // 0) Map (Main)
            NavigationStack {
                MapScreen()
            }
            .tabItem {
                Label(L("الخريطة", "Map"), systemImage: "map.fill")
            }
            .tag(0)

            // 1) Jobs
            NavigationStack {
                JobAdsScreen()
            }
            .tabItem {
                Label(L("وظائف", "Jobs"), systemImage: "briefcase.fill")
            }
            .tag(1)

            // 2) Ads
            NavigationStack {
                AdsHomeView()
            }
            .tabItem {
                Label(L("إعلانات", "Ads"), systemImage: "megaphone.fill")
            }
            .tag(2)

            // 3) Community ✅
            NavigationStack {
                CommunityHubScreen()
            }
            .tabItem {
                Label(L("مجتمع", "Community"), systemImage: "person.3.fill")
            }
            .tag(3)

            // 4) Faith ✅
            NavigationStack {
                FaithToolsScreen()
            }
            .tabItem {
                Label(L("إيمان", "Faith"), systemImage: "moon.stars.fill")
            }
            .tag(4)
        }
    }
}

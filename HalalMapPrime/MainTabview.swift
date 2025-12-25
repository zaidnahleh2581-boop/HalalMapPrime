//
//  MainTabView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var lang: LanguageManager
    @State private var selectedTab: Int = 0

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // 1) Home
            NavigationStack {
                HomeOverviewScreen()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text(L("الرئيسية", "Home"))
            }
            .tag(0)

            // 2) Jobs
            NavigationStack {
                JobAdsScreen()
            }
            .tabItem {
                Image(systemName: "briefcase.fill")
                Text(L("وظائف", "Jobs"))
            }
            .tag(1)

            // 3) Ads
            NavigationStack {
                AdsHomeView()
            }
            .tabItem {
                Image(systemName: "megaphone.fill")
                Text(L("إعلانات", "Ads"))
            }
            .tag(2)

            // 4) Community (وفيها رح نحط زر "المزيد" بدل تبويب More)
            NavigationStack {
                CommunityHubScreen()
            }
            .tabItem {
                Image(systemName: "person.3.fill")
                Text(L("المجتمع", "Community"))
            }
            .tag(3)

            // 5) Faith tools (بديل تبويب المزيد)
            NavigationStack {
                FaithToolsScreen()
            }
            .tabItem {
                Image(systemName: "moon.stars.fill")
                Text(L("الإيمان", "Faith"))
            }
            .tag(4)
        }
    }
}

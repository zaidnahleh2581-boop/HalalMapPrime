//
//  MainTabView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var lang: LanguageManager

    // ✅ Home هو الافتراضي
    @State private var selectedTab: Int = 0

    private var tintColor: Color {
        switch selectedTab {
        case 0: return .orange   // Home
        case 1: return .green    // Jobs
        case 2: return .teal     // Map
        case 3: return .indigo   // Faith
        case 4: return .gray     // More
        default: return .orange
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // 0️⃣ Home
            HomeOverviewScreen(
                onOpenJobs: { selectedTab = 1 },
                onOpenMap: { selectedTab = 2 },
                onOpenFaith: { selectedTab = 3 }
            )
            .tag(0)
            .tabItem {
                Image(systemName: "house.fill")
                Text(lang.isArabic ? "الرئيسية" : "Home")
            }

            // 1️⃣ Jobs (الذهب)
            CommunityHubScreen()
                .tag(1)
                .tabItem {
                    Image(systemName: "briefcase.fill")
                    Text(lang.isArabic ? "وظائف" : "Jobs")
                }

            // 2️⃣ Map
            MapScreen()
                .tag(2)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text(lang.isArabic ? "الخريطة" : "Map")
                }

            // 3️⃣ Faith
            FaithToolsScreen()
                .tag(3)
                .tabItem {
                    Image(systemName: "moon.stars.fill")
                    Text(lang.isArabic ? "الإيمان" : "Faith")
                }

            // 4️⃣ More
            MoreScreen()
                .tag(4)
                .tabItem {
                    Image(systemName: "ellipsis.circle.fill")
                    Text(lang.isArabic ? "المزيد" : "More")
                }
        }
        .tint(tintColor)
    }
}

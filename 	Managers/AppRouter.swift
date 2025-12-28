//
//  AppRouter.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {

    @Published var selectedTab: Int = 0

    // Jobs DeepLink (existing)
    struct JobsDeepLink: Equatable {
        var category: String?
        var filter: JobAdFilter = .all
    }
    @Published var pendingJobsDeepLink: JobsDeepLink? = nil

    func openJobs(category: String?, filter: JobAdFilter = .all) {
        pendingJobsDeepLink = JobsDeepLink(category: category, filter: filter)
        selectedTab = 1
    }

    // ✅ Ads DeepLink (new)
    enum AdsEntry: Equatable {
        case home          // main ads home
        case freeAd        // open FreeAdFormView
        case paidPlans     // open SelectAdPlanView
        case jobsBoard     // open JobAdsBoardView
    }
    
    // ✅ Map DeepLink (new)
    @Published var pendingMapCategory: PlaceCategory? = nil

    func openMap(category: PlaceCategory?) {
        pendingMapCategory = category
        selectedTab = 0
    }
    
    @Published var pendingAdsEntry: AdsEntry? = nil

    func openAds(_ entry: AdsEntry = .home) {
        pendingAdsEntry = entry
        selectedTab = 2
    }
}

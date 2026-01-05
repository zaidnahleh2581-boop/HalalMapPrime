//
//  AdsStore.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine

@MainActor
final class AdsStore: ObservableObject {

    @Published var myAds: [HMPAd] = []

    private let adsKey = "HMP_myAds_local_v1"
    private let freeGiftKey = "HMP_freeGiftUsed_v1"

    // MARK: - Free Gift (ONE TIME EVER)
    var canUseFreeGift: Bool {
        !UserDefaults.standard.bool(forKey: freeGiftKey)
    }

    func markFreeGiftUsed() {
        UserDefaults.standard.set(true, forKey: freeGiftKey)
    }

    // MARK: - Load / Save
    func load() {
        if let data = UserDefaults.standard.data(forKey: adsKey),
           let decoded = try? JSONDecoder().decode([HMPAd].self, from: data) {
            myAds = decoded
        } else {
            myAds = []
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(myAds) {
            UserDefaults.standard.set(data, forKey: adsKey)
        }
    }

    // MARK: - Create Ad (LOCAL NOW)
    func createAdFromDraft(draft: AdDraft, plan: HMPAdPlanKind) {

        let now = Date()
        let expires = Calendar.current.date(byAdding: .day, value: plan.durationDays, to: now) ?? now

        let ad = HMPAd(
            id: UUID().uuidString,
            ownerKey: "local",
            plan: plan,
            isFeatured: plan.isFeatured,
            audience: audienceKey(from: draft.selectedAudience),
            businessName: draft.businessName,
            headline: draft.headline,
            adText: draft.adText,
            phone: draft.phone,
            website: draft.website,
            addressHint: draft.addressHint,
            imageURLs: [],
            createdAt: now,
            expiresAt: expires
        )

        myAds.insert(ad, at: 0)
        save()
    }

    private func audienceKey(from a: AdAudience) -> String {
        switch a {
        case .restaurants: return "restaurants"
        case .mosques:     return "mosques"
        case .shops:       return "shops"
        case .schools:     return "schools"
        }
    }
}

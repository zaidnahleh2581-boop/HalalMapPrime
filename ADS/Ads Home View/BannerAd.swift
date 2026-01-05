//
//  BannerAds.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import SwiftUI

/// الجمهور المستهدف من الإعلان (يستخدم في الفلترة والـ MapScreen)
enum AdAudience: String, CaseIterable, Codable {
    case restaurants   // Restaurants + Food Trucks
    case mosques       // Mosques + (Services optionally)
    case shops         // Shops + Markets + Grocery
    case schools       // Schools + Centers
}

extension AdAudience {
    /// يحدد إذا الإعلان مناسب لفئة Places الحالية في الخريطة
    func matches(category: PlaceCategory?) -> Bool {
        // لو المستخدم على "All" (nil) نسمح للجميع
        guard let category else { return true }

        switch self {
        case .restaurants:
            return category == .restaurant || category == .foodTruck

        case .mosques:
            return category == .mosque || category == .service

        case .shops:
            return category == .shop || category == .market || category == .grocery

        case .schools:
            return category == .school || category == .center
        }
    }
}

/// نموذج الإعلان في الـ Banner
struct BannerAd: Identifiable, Hashable {
    let id: String                 // ✅ ثابت
    let title: String
    let subtitle: String
    let categoryAudience: AdAudience
    let imageSystemName: String    // SF Symbols
}

/// إعلانات تجريبية مؤقتًا (بدل Firebase)
let demoBannerAds: [BannerAd] = [
    BannerAd(
        id: "ad_al_aqsa",
        title: "Al-Aqsa Halal Grill",
        subtitle: "Top Halal Restaurant • Brooklyn, NY",
        categoryAudience: .restaurants,
        imageSystemName: "fork.knife"
    ),
    BannerAd(
        id: "ad_masjid_noor",
        title: "Masjid Noor",
        subtitle: "Daily Prayers • Jummah • Weekend School",
        categoryAudience: .mosques,
        imageSystemName: "sparkles"
    ),
    BannerAd(
        id: "ad_halal_market",
        title: "Halal Market & Shop",
        subtitle: "Groceries • Fresh Meat • Desserts",
        categoryAudience: .shops,
        imageSystemName: "cart.fill"
    ),
    BannerAd(
        id: "ad_islamic_school",
        title: "Islamic School",
        subtitle: "Qur’an • Arabic • Full-Time / Weekend",
        categoryAudience: .schools,
        imageSystemName: "book.fill"
    )
]

//
//  IAPProducts.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

/// ضع هنا Product IDs كما هي في App Store Connect (In-App Purchases / Subscriptions)
enum IAPProducts {

    /// إعلان أسبوعي
    static let weeklyAd: String = "hmp_weekly_ad"

    /// Prime Ad (أفضل ظهور) أسبوعي
    static let primeAd: String = "hmp_prime_ad"

    static let all: [String] = [weeklyAd, primeAd]
}

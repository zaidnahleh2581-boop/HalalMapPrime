//
//  HMPAd.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

struct HMPAd: Identifiable, Codable, Equatable {

    let id: String
    let ownerKey: String

    let plan: HMPAdPlanKind
    let isFeatured: Bool
    let audience: String

    let businessName: String
    let headline: String
    let adText: String

    let phone: String
    let website: String
    let addressHint: String

    let imageURLs: [String]

    let createdAt: Date
    let expiresAt: Date

    var isActive: Bool {
        Date() < expiresAt
    }
}

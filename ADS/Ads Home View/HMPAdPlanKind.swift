//
//  HMPAdPlanKind.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

enum HMPAdPlanKind: String, Identifiable, CaseIterable, Codable {

    case freeOnce
    case weekly
    case monthly
    case prime

    var id: String { rawValue }

    // MARK: - Titles
    var titleEN: String {
        switch self {
        case .freeOnce: return "Free Ad (One Time)"
        case .weekly:   return "Weekly Ad"
        case .monthly:  return "Monthly Ad"
        case .prime:    return "Prime Ad"
        }
    }

    var titleAR: String {
        switch self {
        case .freeOnce: return "إعلان مجاني (مرة واحدة)"
        case .weekly:   return "إعلان أسبوعي"
        case .monthly:  return "إعلان شهري"
        case .prime:    return "إعلان مميز"
        }
    }

    // MARK: - Duration
    var durationDays: Int {
        switch self {
        case .freeOnce: return 30
        case .weekly:   return 7
        case .monthly:  return 30
        case .prime:    return 30
        }
    }

    var durationTextEN: String {
        switch self {
        case .freeOnce: return "30 days (one-time)"
        case .weekly:   return "7 days"
        case .monthly:  return "30 days"
        case .prime:    return "30 days"
        }
    }

    var durationTextAR: String {
        switch self {
        case .freeOnce: return "30 يوم (مرة واحدة)"
        case .weekly:   return "7 أيام"
        case .monthly:  return "30 يوم"
        case .prime:    return "30 يوم"
        }
    }

    // MARK: - Placement
    var placementTextEN: String {
        switch self {
        case .freeOnce:
            return "Featured like Prime • Appears on Home, Ads & Map"
        case .weekly:
            return "Appears in Ads list + Map"
        case .monthly:
            return "Higher priority in Ads list + Map"
        case .prime:
            return "Top placement • Home banner + Ads + Map"
        }
    }

    var placementTextAR: String {
        switch self {
        case .freeOnce:
            return "مميز مثل Prime • يظهر في الرئيسية والإعلانات والخريطة"
        case .weekly:
            return "يظهر في صفحة الإعلانات + الخريطة"
        case .monthly:
            return "أولوية أعلى في الإعلانات + الخريطة"
        case .prime:
            return "أعلى ظهور • بانر رئيسي + إعلانات + خريطة"
        }
    }

    // MARK: - Featured
    var isFeatured: Bool {
        switch self {
        case .freeOnce: return true   // لجذب المستخدم
        case .weekly:   return false
        case .monthly:  return false
        case .prime:    return true
        }
    }

    var tint: Color {
        switch self {
        case .freeOnce: return .green
        case .weekly:   return .cyan
        case .monthly:  return .blue
        case .prime:    return .orange
        }
    }
}

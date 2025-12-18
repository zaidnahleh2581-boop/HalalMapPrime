//
//  Ad.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//  Updated by Zaid Nahleh on 12/18/25.
//

import Foundation
import FirebaseFirestore

struct Ad: Identifiable, Hashable, Codable {

    enum Tier: String, Codable, Hashable {
        case free, standard, prime
    }

    enum Status: String, Codable, Hashable {
        case pending, active, paused, expired
    }

    enum BusinessType: String, Codable, CaseIterable, Identifiable, Hashable {
        case restaurant, grocery, butcher, deli, bakery, cafe, foodTruck, market, other
        var id: String { rawValue }

        var titleEN: String {
            switch self {
            case .restaurant: return "Restaurant"
            case .grocery: return "Grocery"
            case .butcher: return "Butcher"
            case .deli: return "Deli"
            case .bakery: return "Bakery"
            case .cafe: return "Cafe"
            case .foodTruck: return "Food Truck"
            case .market: return "Market"
            case .other: return "Other"
            }
        }

        var titleAR: String {
            switch self {
            case .restaurant: return "مطعم"
            case .grocery: return "بقالة"
            case .butcher: return "ملحمة"
            case .deli: return "ديلي"
            case .bakery: return "مخبز"
            case .cafe: return "كافيه"
            case .foodTruck: return "فود ترك"
            case .market: return "سوق"
            case .other: return "أخرى"
            }
        }
    }

    /// ✅ 15 templates (ONLY defined here)
    enum CopyTemplate: String, Codable, CaseIterable, Identifiable, Hashable {
        case simple
        case halalFocused
        case familyFriendly
        case newOpening
        case communitySupport
        case popular
        case deliveryOrCall
        case locationHighlight
        case bestTimeToVisit
        case specialOfferStyle
        case fridaySpecial
        case weekend
        case easyParking
        case accessible
        case contactNow

        var id: String { rawValue }

        var titleEN: String {
            switch self {
            case .simple: return "Simple"
            case .halalFocused: return "Halal-focused"
            case .familyFriendly: return "Family friendly"
            case .newOpening: return "New opening"
            case .communitySupport: return "Community support"
            case .popular: return "Popular spot"
            case .deliveryOrCall: return "Call / Delivery"
            case .locationHighlight: return "Location highlight"
            case .bestTimeToVisit: return "Best time to visit"
            case .specialOfferStyle: return "Special offer style"
            case .fridaySpecial: return "Friday highlight"
            case .weekend: return "Weekend"
            case .easyParking: return "Easy parking"
            case .accessible: return "Accessibility"
            case .contactNow: return "Contact now"
            }
        }

        var titleAR: String {
            switch self {
            case .simple: return "بسيط"
            case .halalFocused: return "حلال (تركيز)"
            case .familyFriendly: return "مناسب للعائلة"
            case .newOpening: return "افتتاح جديد"
            case .communitySupport: return "دعم المجتمع"
            case .popular: return "مميز/مشهور"
            case .deliveryOrCall: return "اتصال/توصيل"
            case .locationHighlight: return "موقع مميز"
            case .bestTimeToVisit: return "أفضل وقت للزيارة"
            case .specialOfferStyle: return "عرض/ميزة"
            case .fridaySpecial: return "ميزة الجمعة"
            case .weekend: return "الويكند"
            case .easyParking: return "مواقف سهلة"
            case .accessible: return "سهولة الوصول"
            case .contactNow: return "تواصل الآن"
            }
        }
    }

    // MARK: - Core
    let id: String
    let tier: Tier
    var status: Status

    // optional linking
    var placeId: String?

    // local filenames (optional use)
    let imagePaths: [String]

    // business info
    let businessName: String
    let ownerName: String
    let phone: String
    let addressLine: String
    let city: String
    let state: String
    let businessType: BusinessType

    // template
    let template: CopyTemplate

    // duration/cooldown
    let createdAt: Date
    let expiresAt: Date
    let freeCooldownKey: String

    init(
        id: String = UUID().uuidString,
        tier: Tier,
        status: Status = .active,
        placeId: String? = nil,
        imagePaths: [String],
        businessName: String,
        ownerName: String,
        phone: String,
        addressLine: String,
        city: String,
        state: String,
        businessType: BusinessType,
        template: CopyTemplate,
        createdAt: Date = Date(),
        expiresAt: Date,
        freeCooldownKey: String
    ) {
        self.id = id
        self.tier = tier
        self.status = status
        self.placeId = placeId
        self.imagePaths = Array(imagePaths.prefix(3))
        self.businessName = businessName
        self.ownerName = ownerName
        self.phone = phone
        self.addressLine = addressLine
        self.city = city
        self.state = state
        self.businessType = businessType
        self.template = template
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.freeCooldownKey = freeCooldownKey
    }

    var isExpired: Bool { Date() >= expiresAt }
}

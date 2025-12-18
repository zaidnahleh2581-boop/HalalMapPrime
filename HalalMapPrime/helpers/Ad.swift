//
//  Ad.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//

import Foundation
import FirebaseFirestore

struct Ad: Identifiable, Hashable, Codable {

    enum Tier: String, Codable {
        case free, standard, prime
    }

    enum Status: String, Codable {
        case pending, active, paused, expired
    }

    enum BusinessType: String, Codable, CaseIterable, Identifiable {
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

    enum CopyTemplate: String, Codable, CaseIterable, Identifiable {
        case simple, halalVerifiedStyle, familyFriendly, newOpening
        var id: String { rawValue }

        var titleEN: String {
            switch self {
            case .simple: return "Simple"
            case .halalVerifiedStyle: return "Halal-focused"
            case .familyFriendly: return "Family friendly"
            case .newOpening: return "New opening"
            }
        }

        var titleAR: String {
            switch self {
            case .simple: return "بسيط"
            case .halalVerifiedStyle: return "حلال (تركيز)"
            case .familyFriendly: return "مناسب للعائلة"
            case .newOpening: return "افتتاح جديد"
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

    /// ✅ system-generated only (no free user text)
    func generatedCopy(isArabic: Bool) -> String {
        let type = isArabic ? businessType.titleAR : businessType.titleEN
        let location = "\(city), \(state)".trimmingCharacters(in: .whitespacesAndNewlines)

        switch template {
        case .simple:
            return isArabic
            ? "زوروا \(businessName) (\(type)) في \(location). للتواصل: \(phone)."
            : "Visit \(businessName) (\(type)) in \(location). Contact: \(phone)."

        case .halalVerifiedStyle:
            return isArabic
            ? "\(businessName) — \(type) حلال لخدمة المجتمع. العنوان: \(addressLine), \(location). هاتف: \(phone)."
            : "\(businessName) — a halal-focused \(type) serving the community. Address: \(addressLine), \(location). Phone: \(phone)."

        case .familyFriendly:
            return isArabic
            ? "\(businessName) (\(type)) مناسب للعائلات. موقعنا: \(addressLine), \(location). اتصل: \(phone)."
            : "\(businessName) (\(type)) family-friendly. We’re at \(addressLine), \(location). Call: \(phone)."

        case .newOpening:
            return isArabic
            ? "افتتاح/تجديد \(businessName)! \(type) في \(location). زورونا: \(addressLine)."
            : "New (re)opening: \(businessName)! \(type) in \(location). Visit us at \(addressLine)."
        }
    }
}

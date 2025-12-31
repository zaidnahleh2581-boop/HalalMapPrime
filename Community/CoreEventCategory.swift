//
//  CoreEventCategory.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation

enum CoreEventCategory: String, CaseIterable, Identifiable {
    case all
    case iftarRamadan
    case eidPrayer
    case charityFundraising
    case womenLed
    case halalFoodBazaars
    case lecturesTalks
    case weeklyClasses
    case conferences
    case kidsFamily
    case volunteering

    var id: String { rawValue }

    var title: (ar: String, en: String) {
        switch self {
        case .all: return ("الكل", "All")
        case .iftarRamadan: return ("رمضان / إفطار", "Ramadan / Iftar")
        case .eidPrayer: return ("العيد", "Eid Prayer")
        case .charityFundraising: return ("تبرعات", "Charity")
        case .womenLed: return ("فعاليات نسائية", "Women-led")
        case .halalFoodBazaars: return ("طعام / بازار", "Food / Bazaar")
        case .lecturesTalks: return ("محاضرات", "Lectures")
        case .weeklyClasses: return ("دروس أسبوعية", "Weekly Classes")
        case .conferences: return ("مؤتمرات", "Conferences")
        case .kidsFamily: return ("عائلة وأطفال", "Kids & Family")
        case .volunteering: return ("تطوع", "Volunteering")
        }
    }

    /// Map your existing templateId -> core category (no DB change needed).
    func matches(event: EventAd) -> Bool {
        if self == .all { return true }

        let t = event.templateId.lowercased()

        switch self {
        case .iftarRamadan:
            return t == "ramadaniftar"

        case .eidPrayer:
            return t == "eidprayer"

        case .charityFundraising:
            return t == "charityfundraiser"

        case .womenLed:
            // ✅ "Sisters" template counts as women-led
            return t == "sistershalaqa"

        case .halalFoodBazaars:
            return t == "foodbazaar"

        case .lecturesTalks:
            return t == "lecturetallk" || t == "lecturetallk" // safety typo (won't hurt)
            || t == "lecturetallk"
            || t == "lecturetalk"

        case .weeklyClasses:
            // Quran circle & weekly halaqas/classes
            return t == "qurancircle" || t == "fridayprayer"

        case .conferences:
            // You don't have a conference template yet -> use communityMeeting as "conference-like"
            return t == "communitymeeting"

        case .kidsFamily:
            return t == "weekendschool" || t == "youthnight"

        case .volunteering:
            return t == "volunteerdrive"

        case .all:
            return true
        }
    }
}

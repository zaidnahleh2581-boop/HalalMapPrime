//
//  EventTemplate.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/29/25.

import Foundation

enum EventTemplate: String, CaseIterable, Identifiable {
    case fridayPrayer
    case quranCircle
    case youthNight
    case sistersHalaqa
    case eidPrayer
    case ramadanIftar
    case charityFundraiser
    case communityMeeting
    case lectureTalk
    case foodBazaar
    case weekendSchool
    case volunteerDrive

    var id: String { rawValue }

    var displayTitle: (ar: String, en: String) {
        switch self {
        case .fridayPrayer: return ("صلاة الجمعة", "Friday Prayer")
        case .quranCircle: return ("حلقة قرآن", "Quran Circle")
        case .youthNight: return ("ليلة الشباب", "Youth Night")
        case .sistersHalaqa: return ("حلقة أخوات", "Sisters Halaqa")
        case .eidPrayer: return ("صلاة العيد", "Eid Prayer")
        case .ramadanIftar: return ("إفطار رمضان", "Ramadan Iftar")
        case .charityFundraiser: return ("تبرعات / حملة خيرية", "Charity Fundraiser")
        case .communityMeeting: return ("اجتماع المجتمع", "Community Meeting")
        case .lectureTalk: return ("محاضرة / درس", "Lecture / Talk")
        case .foodBazaar: return ("بازار / أكل", "Food Bazaar")
        case .weekendSchool: return ("مدرسة نهاية الأسبوع", "Weekend School")
        case .volunteerDrive: return ("تطوع / حملة", "Volunteer Drive")
        }
    }

    func text(isArabic: Bool, city: String, place: String, dateText: String, phone: String) -> String {
        // ملاحظة: النصوص “Apple-friendly” ومباشرة بدون مبالغات/وعود
        func safe(_ s: String, fallback: String) -> String { s.trimmingCharacters(in: .whitespaces).isEmpty ? fallback : s }

        let c = safe(city, fallback: isArabic ? "NY/NJ" : "NY/NJ")
        let p = safe(place, fallback: isArabic ? "المكان" : "the venue")
        let d = safe(dateText, fallback: isArabic ? "قريباً" : "soon")
        let ph = safe(phone, fallback: isArabic ? "سيتم تزويدك لاحقاً" : "to be provided")

        switch self {

        case .charityFundraiser:
            return isArabic
            ? "فعالية تبرعات في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Charity fundraiser at \(p) — \(c) on \(d). Info: \(ph)."

        case .ramadanIftar:
            return isArabic
            ? "إفطار جماعي في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Community iftar at \(p) — \(c) on \(d). Info: \(ph)."

        case .eidPrayer:
            return isArabic
            ? "صلاة العيد في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Eid prayer at \(p) — \(c) on \(d). Info: \(ph)."

        case .fridayPrayer:
            return isArabic
            ? "تنبيه صلاة الجمعة في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Friday prayer notice at \(p) — \(c) on \(d). Info: \(ph)."

        case .quranCircle:
            return isArabic
            ? "حلقة قرآن في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Quran circle at \(p) — \(c) on \(d). Info: \(ph)."

        case .youthNight:
            return isArabic
            ? "ليلة شباب في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Youth night at \(p) — \(c) on \(d). Info: \(ph)."

        case .sistersHalaqa:
            return isArabic
            ? "حلقة أخوات في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Sisters halaqa at \(p) — \(c) on \(d). Info: \(ph)."

        case .communityMeeting:
            return isArabic
            ? "اجتماع مجتمع في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Community meeting at \(p) — \(c) on \(d). Info: \(ph)."

        case .lectureTalk:
            return isArabic
            ? "محاضرة/درس في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Lecture/talk at \(p) — \(c) on \(d). Info: \(ph)."

        case .foodBazaar:
            return isArabic
            ? "بازار/أطعمة في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Food bazaar at \(p) — \(c) on \(d). Info: \(ph)."

        case .weekendSchool:
            return isArabic
            ? "مدرسة/نشاط نهاية الأسبوع في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Weekend school/activity at \(p) — \(c) on \(d). Info: \(ph)."

        case .volunteerDrive:
            return isArabic
            ? "حملة تطوع في \(p) — \(c) بتاريخ \(d). للاستفسار: \(ph)."
            : "Volunteer drive at \(p) — \(c) on \(d). Info: \(ph)."
        }
    }
}

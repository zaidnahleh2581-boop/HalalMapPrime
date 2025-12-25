//
//  JobAdsModels.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import Foundation

/// نوع إعلان الوظيفة (باحث عن عمل / صاحب عمل يبحث عن موظف)
enum JobAdType: String, CaseIterable, Identifiable {
    case lookingForJob = "lookingForJob"   // أبحث عن عمل
    case hiring         = "hiring"         // أبحث عن موظف

    var id: String { rawValue }

    var localizedTitleArabic: String {
        switch self {
        case .lookingForJob: return "أبحث عن عمل"
        case .hiring:        return "أبحث عن موظف"
        }
    }

    var localizedTitleEnglish: String {
        switch self {
        case .lookingForJob: return "Looking for a job"
        case .hiring:        return "Hiring"
        }
    }
}

/// قطاع العمل (مطاعم، سوبرماركت، مساجد...)
enum JobSector: String, CaseIterable, Identifiable {
    case restaurants     = "restaurants"
    case supermarkets    = "supermarkets"
    case butcher         = "butcher"
    case shops           = "shops"
    case mosques         = "mosques"
    case schools         = "schools"
    case professional    = "professional"
    case construction    = "construction"

    var id: String { rawValue }

    var titleArabic: String {
        switch self {
        case .restaurants:  return "مطاعم وكافيهات"
        case .supermarkets: return "سوبرماركت وبقالات"
        case .butcher:      return "ملاحم"
        case .shops:        return "محلات تجارية"
        case .mosques:      return "مساجد ومراكز"
        case .schools:      return "مدارس"
        case .professional: return "وظائف مهنية"
        case .construction: return "بناء وكهرباء وسباكة"
        }
    }

    var titleEnglish: String {
        switch self {
        case .restaurants:  return "Restaurants & Cafes"
        case .supermarkets: return "Supermarkets & Groceries"
        case .butcher:      return "Butcher shops"
        case .shops:        return "Retail shops"
        case .mosques:      return "Mosques & centers"
        case .schools:      return "Schools"
        case .professional: return "Professional jobs"
        case .construction: return "Construction / Electric / Plumbing"
        }
    }
}

/// نموذج إعلان الوظيفة الذي نستخدمه داخل التطبيق
struct JobAd: Identifiable {
    let id: String

    let type: JobAdType       // باحث عن عمل / صاحب عمل
    let sector: JobSector     // القطاع
    let templateId: Int       // رقم القالب المستخدم

    let title: String         // عنوان مختصر
    let details: String       // النص النهائي (جاهز)
    let city: String
    let contact: String       // رقم الهاتف
    let ownerName: String     // اسم صاحب الإعلان

    let createdAt: Date       // متى تم نشر الإعلان
    let expiresAt: Date       // متى ينتهي (٧ أيام)
    let isFree: Bool          // هل هذا الإعلان مجاني أم مدفوع
}

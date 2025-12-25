
import Foundation
import SwiftUI

/// الجمهور المستهدف من الإعلان (يستخدم في الفلترة والـ MapScreen)
enum AdAudience: String, CaseIterable, Codable {
    case restaurants   // مطاعم + Food Trucks
    case mosques       // مساجد + خدمات إسلامية
    case shops         // متاجر وأسواق
    case schools       // مدارس ومراكز تعليمية
}

/// نموذج الإعلان في الـ Banner
struct BannerAd: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let categoryAudience: AdAudience   // ← هذا اللي يربط الإعلان بالفئة
    let imageSystemName: String       // اسم الأيقونة من SF Symbols
}

/// إعلانات تجريبية مؤقتًا (بدل Firebase)
let demoBannerAds: [BannerAd] = [
    BannerAd(
        title: "Al-Aqsa Halal Grill",
        subtitle: "Top Halal Restaurant • Brooklyn, NY",
        categoryAudience: .restaurants,
        imageSystemName: "fork.knife"
    ),
    BannerAd(
        title: "Masjid Noor",
        subtitle: "Daily Prayers • Jummah • Weekend School",
        categoryAudience: .mosques,
        imageSystemName: "sparkles"
    ),
    BannerAd(
        title: "Halal Market & Shop",
        subtitle: "Groceries • Fresh Meat • Desserts",
        categoryAudience: .shops,
        imageSystemName: "cart.fill"
    ),
    BannerAd(
        title: "Islamic School",
        subtitle: "Qur’an • Arabic • Full-Time / Weekend",
        categoryAudience: .schools,
        imageSystemName: "book.fill"
    )
]

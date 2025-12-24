import Foundation
import SwiftUI

// كل أنواع الأماكن في الأب
enum PlaceCategory: String, CaseIterable, Identifiable, Codable {

    // ✅ القائمة المختصرة المعتمدة (اللي بدنا نعرضها للمستخدم)
    case restaurant = "Restaurant"
    case grocery    = "Grocery"
    case school     = "School"
    case mosque     = "Mosque"
    case service    = "Service"
    case market     = "Market"
    case shop       = "Shop"
    case foodTruck  = "Food Truck"   // ✅ نتركها ظاهرة

    // ⚠️ حالات موجودة بالمشروع لكن مخفية عن المستخدم
    case center     = "Center"
    case funeral    = "Funeral"       // ❌ مخفية (أماكن دفن)

    var id: String { rawValue }

    // MARK: - ✅ القائمة التي تظهر في الفلاتر (بدون Funeral)
    static var shortCases: [PlaceCategory] {
        [
            .restaurant,
            .grocery,
            .mosque,
            .school,
            .service,
            .shop,
            .market,
            .foodTruck
        ]
    }

    // MARK: - Display Name (قديم) — للحفاظ على التوافق
    var displayName: String {
        displayName(isArabic: false)
    }

    // MARK: - Display Name (عربي / إنجليزي)
    func displayName(isArabic: Bool) -> String {
        switch self {
        case .restaurant: return isArabic ? "مطاعم" : "Restaurants"
        case .grocery:    return isArabic ? "بقالات" : "Groceries"
        case .school:     return isArabic ? "مدارس" : "Schools"
        case .mosque:     return isArabic ? "مساجد" : "Mosques"
        case .service:    return isArabic ? "خدمات" : "Services"
        case .market:     return isArabic ? "أسواق" : "Markets"
        case .shop:       return isArabic ? "محلات" : "Shops"
        case .foodTruck:  return isArabic ? "فود ترك" : "Food Trucks"

        // مخفية
        case .center:     return isArabic ? "مراكز" : "Centers"
        case .funeral:    return isArabic ? "جنائز" : "Funeral"
        }
    }

    // MARK: - Google Places Type (محسّن)
    var googleType: String {
        switch self {
        case .restaurant: return "restaurant"
        case .grocery:    return "supermarket"
        case .school:     return "school"
        case .mosque:     return "mosque"
        case .service:    return "establishment"
        case .market:     return "shopping_mall"
        case .shop:       return "store"
        case .foodTruck:  return "meal_takeaway"

        // مخفية
        case .center:     return "point_of_interest"
        case .funeral:    return "funeral_home"
        }
    }

    // MARK: - لون الخريطة
    var mapColor: Color {
        switch self {
        case .restaurant: return .red
        case .grocery:    return .green
        case .school:     return .blue
        case .mosque:     return .mint
        case .service:    return .orange
        case .market:     return .brown
        case .shop:       return .pink
        case .foodTruck:  return .yellow
        case .center:     return .teal
        case .funeral:    return .black
        }
    }

    // MARK: - Emoji
    var emoji: String {
        switch self {
        case .restaurant: return "🍽️"
        case .grocery:    return "🛒"
        case .school:     return "🏫"
        case .mosque:     return "🕌"
        case .service:    return "🛠️"
        case .market:     return "🛍️"
        case .shop:       return "🏪"
        case .foodTruck:  return "🚚"
        case .center:     return "📍"
        case .funeral:    return "⚰️"
        }
    }
}

import Foundation
import SwiftUI

// كل أنواع الأماكن في الأب
enum PlaceCategory: String, CaseIterable, Identifiable, Codable {
    case restaurant = "Restaurant"
    case grocery    = "Grocery"
    case school     = "School"
    case mosque     = "Mosque"
    case service    = "Service"
    case foodTruck  = "Food Truck"
    case market     = "Market"
    case shop       = "Shop"
    case center     = "Center"
    case funeral    = "Funeral"
    case womenSalon  = "Women Salon"
    case womenGym    = "Women Gym"
    case womenClinic = "Women Clinic"
    
    var id: String { rawValue }

    // الاسم الظاهر فوق الفلاتر
    var displayName: String {
        switch self {
        case .restaurant: return "Restaurants"
        case .grocery:    return "Groceries"
        case .school:     return "Schools"
        case .mosque:     return "Mosques"
        case .service:    return "Services"
        case .foodTruck:  return "Food Trucks"
        case .market:     return "Markets"
        case .shop:       return "Shops"
        case .center:     return "Centers"
        case .funeral:    return "Funeral"
        case .womenSalon:  return "Women Salon"
        case .womenGym:    return "Women Gym"
        case .womenClinic: return "Women Clinic"        }
    }

    // نوع Google Places – هذا اللي بيستخدمه GooglePlacesService
    var googleType: String {
        switch self {
        case .restaurant: return "restaurant"
        case .grocery:    return "grocery_or_supermarket"
        case .school:     return "school"
        case .mosque:     return "mosque"
        case .service:    return "store"
        case .foodTruck:  return "meal_takeaway"
        case .market:     return "supermarket"
        case .shop:       return "store"
        case .center:     return "point_of_interest"
        case .funeral:    return "funeral_home"
        case .womenSalon:  return "beauty_salon"
        case .womenGym:    return "gym"
        case .womenClinic: return "doctor"
        }
    }

    // لون العلامة على الخريطة حسب النوع
    var mapColor: Color {
        switch self {
        case .restaurant: return .red
        case .grocery:    return .green
        case .school:     return .blue
        case .mosque:     return .mint
        case .service:    return .orange
        case .foodTruck:  return .yellow
        case .market:     return .brown
        case .shop:       return .pink
        case .center:     return .teal
        case .funeral:    return .black
        case .womenSalon:  return .purple
        case .womenGym:    return .indigo
        case .womenClinic: return .cyan        }
    }

    // الإيموجي اللي بنحطه في الليست أو البانر
    var emoji: String {
        switch self {
        case .restaurant: return "🍽️"
        case .grocery:    return "🛒"
        case .school:     return "🏫"
        case .mosque:     return "🕌"
        case .service:    return "🛠️"
        case .foodTruck:  return "🚚"
        case .market:     return "🛍️"
        case .shop:       return "🏪"
        case .center:     return "📍"
        case .funeral:    return "⚰️"
        case .womenSalon:  return "💇‍♀️"
        case .womenGym:    return "🏋️‍♀️"
        case .womenClinic: return "👩‍⚕️"        }
    }
}

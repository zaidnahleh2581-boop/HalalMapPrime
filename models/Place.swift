import Foundation
import CoreLocation

struct Place: Identifiable, Hashable {
    let id: String
    let name: String
    let address: String
    let cityState: String
    let latitude: Double
    let longitude: Double
    let category: PlaceCategory
    let rating: Double
    let reviewCount: Int
    let deliveryAvailable: Bool
    let isCertified: Bool

    // ✅ إضافات للمرحلة 3 (اختيارية)
    let phoneNumber: String?
    let website: String?

    // ✅ Coordinate للشاشة والخريطة
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // ✅ عشان PlaceDetailsSheet يعرض عنوان مرتب
    var formattedAddress: String {
        "\(address), \(cityState)"
    }

    // ✅ توافق مع اسم Google Places الشائع
    var userRatingsTotal: Int {
        reviewCount
    }

    // ✅ Init يحافظ على التوافق مع أي كود قديم عندك
    init(
        id: String,
        name: String,
        address: String,
        cityState: String,
        latitude: Double,
        longitude: Double,
        category: PlaceCategory,
        rating: Double,
        reviewCount: Int,
        deliveryAvailable: Bool,
        isCertified: Bool,
        phoneNumber: String? = nil,
        website: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.cityState = cityState
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.rating = rating
        self.reviewCount = reviewCount
        self.deliveryAvailable = deliveryAvailable
        self.isCertified = isCertified
        self.phoneNumber = phoneNumber
        self.website = website
    }
}

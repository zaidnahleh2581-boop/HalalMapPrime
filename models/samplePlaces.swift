import Foundation
import CoreLocation

// MARK: - Sample Places (For Testing Only)

let samplePlaces: [Place] = [
    Place(
        id: "1",
        name: "Al-Aqsa Halal Grill",
        address: "123 Atlantic Ave",
        cityState: "Brooklyn, NY",
        latitude: 40.6900,
        longitude: -73.9900,
        category: .restaurant,
        rating: 4.2,
        reviewCount: 138,
        deliveryAvailable: true,
        isCertified: true
    ),
    Place(
        id: "2",
        name: "Madina Grocery",
        address: "55 Church Ave",
        cityState: "Brooklyn, NY",
        latitude: 40.6500,
        longitude: -73.9800,
        category: .grocery,
        rating: 4.8,
        reviewCount: 62,
        deliveryAvailable: false,
        isCertified: true
    )
]

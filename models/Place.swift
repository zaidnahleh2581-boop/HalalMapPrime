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
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

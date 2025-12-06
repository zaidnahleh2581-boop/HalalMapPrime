import Foundation

// MARK: - Google Places JSON Models

/// ردّ Google Places للـ Nearby Search
struct GooglePlacesResponse: Codable {
    let results: [GooglePlaceResult]
}

/// كل نتيجة (مكان واحد) من Google Places
struct GooglePlaceResult: Codable {
    let place_id: String?
    let name: String?
    let vicinity: String?
    let rating: Double?
    let user_ratings_total: Int?
    let geometry: Geometry?
}

struct Geometry: Codable {
    let location: Location?
}

struct Location: Codable {
    let lat: Double?
    let lng: Double?
}

//
//  GooglePlacesService.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Updated by Zaid Nahleh on 12/21/25
//
//  Google Places Nearby Search:
//  - 5 miles radius
//  - keyword=halal
//  - Safe decoding to Place model
//

import Foundation
import CoreLocation

/// خدمة الاتصال بـ Google Places
final class GooglePlacesService {

    static let shared = GooglePlacesService()
    private init() {}

    // ⚠️ ضع الـ API Key هنا (لا ترفعه على GitHub public)
    private let GOOGLE_API_KEY = "REDACTED_KEY_HERE"

    /// بحث عن أماكن حلال بالقرب من إحداثيات معيّنة
    func searchNearbyHalal(
        coordinate: CLLocationCoordinate2D,
        category: PlaceCategory?,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {

        let googleType = category?.googleType ?? "restaurant"

        // ✅ 5 miles ≈ 8047 meters
        let radius = 8047

        // ✅ Improve relevance
        let keyword = "halal"

        let urlString =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json" +
        "?location=\(coordinate.latitude),\(coordinate.longitude)" +
        "&radius=\(radius)" +
        "&type=\(googleType)" +
        "&keyword=\(keyword)" +
        "&key=\(GOOGLE_API_KEY)"

        guard let url = URL(string: urlString) else {
            completion(.success([]))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in

            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.success([])) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)

                let places: [Place] = decoded.results.compactMap { result in
                    guard
                        let lat = result.geometry?.location?.lat,
                        let lng = result.geometry?.location?.lng
                    else { return nil }

                    let address = result.vicinity ?? ""
                    return Place(
                        id: result.place_id ?? UUID().uuidString,
                        name: result.name ?? "Unknown",
                        address: address,
                        cityState: "", // (سنحسّنه لاحقاً عبر Details/Geocoding)
                        latitude: lat,
                        longitude: lng,
                        category: category ?? .restaurant,
                        rating: result.rating ?? 0,
                        reviewCount: result.user_ratings_total ?? 0,
                        deliveryAvailable: false,
                        isCertified: false
                    )
                }

                DispatchQueue.main.async {
                    completion(.success(places))
                }

            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }

        task.resume()
    }
}

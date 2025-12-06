import Foundation
import CoreLocation

/// خدمة الاتصال بـ Google Places
final class GooglePlacesService {

    static let shared = GooglePlacesService()

    private init() {}

    // ضع هنا الـ API Key تبع Google Places
    private let GOOGLE_API_KEY = "AIzaSyAW7eNiYkhbmyrgNzOPU0UwWhytUGTzI_I"// 

    /// بحث عن أماكن حلال بالقرب من إحداثيات معيّنة
    func searchNearbyHalal(
        coordinate: CLLocationCoordinate2D,
        category: PlaceCategory?,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        // نوع المكان في Google (restaurant, mosque, grocery, ...)
        let googleType = category?.googleType ?? "restaurant"

        // نصف قطر البحث بالمتر (هنا 5000 = 5 كم)
        let radius = 5000

        let urlString =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json" +
        "?location=\(coordinate.latitude),\(coordinate.longitude)" +
        "&radius=\(radius)" +
        "&type=\(googleType)" +
        "&key=\(GOOGLE_API_KEY)"

        guard let url = URL(string: urlString) else {
            print("❌ [GooglePlacesService] Invalid URL")
            completion(.success([]))
            return
        }

        // طلب الشبكة
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // DEBUG: اطبع JSON اللي جاي من Google
            if let data = data, let json = String(data: data, encoding: .utf8) {
                print("\n🔵 RAW GOOGLE JSON:\n\(json)\n")
            }
            // 1) خطأ شبكة
            if let error = error {
                print("❌ [GooglePlacesService] Network error:", error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            // 2) لا يوجد بيانات
            guard let data = data else {
                print("❌ [GooglePlacesService] No data in response")
                DispatchQueue.main.async {
                    completion(.success([]))
                }
                return
            }

            do {
                // 3) فك JSON إلى موديلاتنا
                let decoded = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)

                // 4) تحويل GooglePlaceResult → Place (الموديل الموحد عندك)
                let places: [Place] = decoded.results.compactMap { result in
                    // نأخذ الإحداثيات من geometry.location
                    guard
                        let lat = result.geometry?.location?.lat,
                        let lng = result.geometry?.location?.lng
                    else {
                        return nil
                    }

                    return Place(
                        id: result.place_id ?? UUID().uuidString,
                        name: result.name ?? "Unknown",
                        address: result.vicinity ?? "",
                        cityState: "",                           // تقدر تعبيه لاحقًا لو حاب
                        latitude: lat,
                        longitude: lng,
                        category: category ?? .restaurant,
                        rating: result.rating ?? 0,
                        reviewCount: result.user_ratings_total ?? 0,
                        deliveryAvailable: false,
                        isCertified: false
                    )
                }

                print("✅ [GooglePlacesService] Google returned \(places.count) places")

                DispatchQueue.main.async {
                    completion(.success(places))
                }
            } catch {
                print("❌ [GooglePlacesService] JSON decode error:", error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }
}

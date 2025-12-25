import Foundation

final class AppConfig {
    static let shared = AppConfig()
    
    let googlePlacesAPIKey: String
    let isGooglePlacesEnabled: Bool = true    // 👈 لو خفت من Google بكرة خليه false
    
    private init() {
        guard
            let url = Bundle.main.url(forResource: "APIConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
            let key = plist["GOOGLE_PLACES_API_KEY"] as? String,
            !key.isEmpty
        else {
            fatalError("❌ Missing or invalid GOOGLE_PLACES_API_KEY in APIConfig.plist")
        }
        
        self.googlePlacesAPIKey = key
    }
}

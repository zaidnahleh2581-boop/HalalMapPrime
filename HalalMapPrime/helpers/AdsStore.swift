import Foundation
import Combine

final class AdsStore: ObservableObject {

    static let shared = AdsStore()

    @Published private(set) var ads: [Ad] = []

    private init() { }

    func activeAdsSorted() -> [Ad] {
        ads
            .filter { $0.status == .active }
            .sorted { a, b in
                let ra = a.tier.priority
                let rb = b.tier.priority
                if ra != rb { return ra > rb }          // Prime أول
                return a.createdAt > b.createdAt        // الأحدث أول
            }
    }

    func add(_ ad: Ad) {
        ads.insert(ad, at: 0)
    }

    func remove(adId: String) {
        ads.removeAll { $0.id == adId }
    }
}

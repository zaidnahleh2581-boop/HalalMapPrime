import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class AdsStore: ObservableObject {

    static let shared = AdsStore()

    @Published private(set) var ads: [Ad] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private init() {}

    // MARK: - Firestore Listening

    func startListeningAds() {
        stopListening()

        listener = db.collection("ads")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let docs = snapshot?.documents {
                    self.ads = docs.compactMap { doc in
                        try? doc.data(as: Ad.self)
                    }
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Local helpers (used by Views)

    func add(_ ad: Ad) {
        ads.insert(ad, at: 0)
    }

    func remove(adId: String) {
        ads.removeAll { $0.id == adId }
    }

    // MARK: - Active Ads

    func activeAdsSorted() -> [Ad] {
        ads
            .filter { $0.status == .active && !$0.isExpired }
            .sorted {
                if $0.tier.priority != $1.tier.priority {
                    return $0.tier.priority > $1.tier.priority
                }
                return $0.createdAt > $1.createdAt
            }
    }

    // MARK: - Free Ad cooldown logic

    func canCreateFreeAd(cooldownKey: String) -> Bool {
        guard let last = ads
            .filter({ $0.tier == .free && $0.freeCooldownKey == cooldownKey })
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
        else { return true }

        let days30: TimeInterval = 30 * 24 * 60 * 60
        return Date().timeIntervalSince(last.createdAt) >= days30
    }

    func freeAdCooldownRemainingDays(cooldownKey: String) -> Int {
        guard let last = ads
            .filter({ $0.tier == .free && $0.freeCooldownKey == cooldownKey })
            .sorted(by: { $0.createdAt > $1.createdAt })
            .first
        else { return 0 }

        let days30: TimeInterval = 30 * 24 * 60 * 60
        let remaining = max(0, days30 - Date().timeIntervalSince(last.createdAt))
        return Int(ceil(remaining / (24 * 60 * 60)))
    }
}

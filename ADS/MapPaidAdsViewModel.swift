import Foundation
import FirebaseFirestore
import Combine


// موديل بسيط للإعلان المدفوع الذي سيظهر في البنر
struct MapPaidAd: Identifiable {
    let id: String
    let planType: PaidAdPlanType
    let status: String
    let createdAt: Date?
    let durationDays: Int
    let priceUSD: Double

    // تاريخ الانتهاء محسوب من createdAt + durationDays
    var endDate: Date? {
        guard let createdAt else { return nil }
        return Calendar.current.date(byAdding: .day, value: durationDays, to: createdAt)
    }

    var isActiveNow: Bool {
        guard let end = endDate else { return true }
        return Date() <= end
    }
}

final class MapPaidAdsViewModel: ObservableObject {

    @Published var activeAds: [MapPaidAd] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        DispatchQueue.main.async {
            self.startListening()
        }
    }

    deinit {
        listener?.remove()
    }

    private func startListening() {
        listener = db.collection("paidAdOrders")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error listening for paidAdOrders: \(error.localizedDescription)")
                    return
                }

                guard let docs = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.activeAds = []
                    }
                    return
                }

                let ads: [MapPaidAd] = docs.compactMap { doc in
                    let data = doc.data()

                    guard
                        let planRaw = data["planType"] as? String,
                        let planType = PaidAdPlanType(rawValue: planRaw)
                    else { return nil }

                    let status = data["status"] as? String ?? "pending"
                    let durationDays = data["durationDays"] as? Int ?? planType.durationDays
                    let price = data["priceUSD"] as? Double ?? 0.0
                    let createdAt: Date?

                    if let ts = data["createdAt"] as? Timestamp {
                        createdAt = ts.dateValue()
                    } else {
                        createdAt = nil
                    }

                    let ad = MapPaidAd(
                        id: doc.documentID,
                        planType: planType,
                        status: status,
                        createdAt: createdAt,
                        durationDays: durationDays,
                        priceUSD: price
                    )

                    // اعتبر الإعلانات pending أو active فقط، وغير منتهية
                    guard ad.isActiveNow,
                          ad.status == "pending" || ad.status == "active"
                    else { return nil }

                    return ad
                }

                DispatchQueue.main.async {
                    self.activeAds = ads
                }
            }
    }
}

import Foundation
import FirebaseFirestore

// نوع الباقة المدفوعة
enum PaidAdPlanType: String {
    case daily
    case weekly
    case monthly

    // عدد الأيام لكل باقة
    var durationDays: Int {
        switch self {
        case .daily:   return 1
        case .weekly:  return 7
        case .monthly: return 30
        }
    }

    // السعر التقريبي (مثال – لاحقاً نربطه مع StoreKit)
    var examplePriceUSD: Double {
        switch self {
        case .daily:   return 4.99
        case .weekly:  return 14.99
        case .monthly: return 49.99
        }
    }
}

// موديل طلب إعلان مدفوع (Order)
struct PaidAdOrder: Identifiable {
    let id: String
    let planType: PaidAdPlanType
    let durationDays: Int
    let priceUSD: Double
    let status: String      // pending / active / expired
    let createdAt: Date?

    init?(doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        guard
            let planRaw = data["planType"] as? String,
            let planType = PaidAdPlanType(rawValue: planRaw)
        else {
            return nil
        }

        self.id = doc.documentID
        self.planType = planType
        self.durationDays = data["durationDays"] as? Int ?? planType.durationDays
        self.priceUSD = data["priceUSD"] as? Double ?? planType.examplePriceUSD
        self.status = data["status"] as? String ?? "pending"

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }
    }
}

// خدمة حفظ طلبات الإعلانات المدفوعة في Firestore
final class PaidAdsService {

    static let shared = PaidAdsService()

    private let db = Firestore.firestore()
    private let collectionName = "paidAdOrders"

    private init() {}

    /// إنشاء طلب جديد لباقات الإعلانات المدفوعة
    func createOrder(
        plan: PaidAdPlanType,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let data: [String: Any] = [
            "planType"     : plan.rawValue,
            "durationDays" : plan.durationDays,
            "priceUSD"     : plan.examplePriceUSD,
            "status"       : "pending",                 // لاحقاً تصبح active بعد الدفع الحقيقي
            "createdAt"    : FieldValue.serverTimestamp()
        ]

        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

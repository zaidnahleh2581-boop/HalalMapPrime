import Foundation
import FirebaseFirestore
import FirebaseAuth

/// موديل إعلان فعالية في المدينة
struct EventAd: Identifiable {
    let id: String
    let ownerId: String
    let title: String
    let city: String
    let placeName: String
    let date: Date
    let description: String
    let phone: String
    let templateId: String

    let createdAt: Date
    let updatedAt: Date?
    let deletedAt: Date?

    init?(snapshot: DocumentSnapshot) {
        let data = snapshot.data() ?? [:]

        guard
            let ownerId = data["ownerId"] as? String,
            let title = data["title"] as? String,
            let city = data["city"] as? String,
            let placeName = data["placeName"] as? String,
            let description = data["description"] as? String,
            let phone = data["phone"] as? String,
            let dateTS = data["date"] as? Timestamp,
            let createdTS = data["createdAt"] as? Timestamp
        else {
            return nil
        }

        self.id = snapshot.documentID
        self.ownerId = ownerId
        self.title = title
        self.city = city
        self.placeName = placeName
        self.description = description
        self.phone = phone
        self.date = dateTS.dateValue()
        self.createdAt = createdTS.dateValue()

        self.templateId = data["templateId"] as? String ?? "communityMeeting"

        if let ts = data["updatedAt"] as? Timestamp {
            self.updatedAt = ts.dateValue()
        } else {
            self.updatedAt = nil
        }

        if let ts = data["deletedAt"] as? Timestamp {
            self.deletedAt = ts.dateValue()
        } else {
            self.deletedAt = nil
        }
    }
}

/// خدمة التعامل مع Firestore لإعلانات الفعاليات
final class EventAdsService {

    static let shared = EventAdsService()

    private let db = Firestore.firestore()
    private let collectionName = "cityEventAds"

    private init() {}

    /// الاستماع للفعاليات القادمة (من اليوم وما بعده) بترتيب التاريخ
    @discardableResult
    func observeUpcomingEvents(
        completion: @escaping (Result<[EventAd], Error>) -> Void
    ) -> ListenerRegistration {

        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayTS = Timestamp(date: todayStart)

        // ✅ فلترة: غير محذوف + تاريخ >= اليوم
        return db.collection(collectionName)
            .whereField("deletedAt", isEqualTo: NSNull())
            .whereField("date", isGreaterThanOrEqualTo: todayTS)
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let docs = snapshot?.documents ?? []
                let events = docs.compactMap { EventAd(snapshot: $0) }
                completion(.success(events))
            }
    }

    /// إنشاء إعلان فعالية جديد
    func createEventAd(
        title: String,
        city: String,
        placeName: String,
        date: Date,
        description: String,
        phone: String,
        templateId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }

        let data: [String: Any] = [
            "ownerId": uid,
            "title": title,
            "city": city,
            "placeName": placeName,
            "date": Timestamp(date: date),
            "description": description,
            "phone": phone,
            "templateId": templateId,

            // ✅ soft delete field موجود و null عشان نقدر نفلتره
            "deletedAt": NSNull(),
            "updatedAt": NSNull(),

            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection(collectionName).addDocument(data: data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    /// تحديث إعلان (لصاحبه فقط - نتحقق بالكلينت؛ rules لازم كمان)
    func updateEventAd(
        adId: String,
        title: String,
        city: String,
        placeName: String,
        date: Date,
        description: String,
        phone: String,
        templateId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let data: [String: Any] = [
            "title": title,
            "city": city,
            "placeName": placeName,
            "date": Timestamp(date: date),
            "description": description,
            "phone": phone,
            "templateId": templateId,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        db.collection(collectionName).document(adId).updateData(data) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    /// حذف (soft delete)
    func softDeleteEventAd(
        adId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection(collectionName).document(adId).updateData([
            "deletedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

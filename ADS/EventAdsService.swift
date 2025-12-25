import Foundation
import FirebaseFirestore

/// موديل إعلان فعالية في المدينة
struct EventAd: Identifiable {
    let id: String
    let title: String
    let city: String
    let placeName: String
    let date: Date
    let description: String
    let phone: String
    let createdAt: Date

    init?(snapshot: DocumentSnapshot) {
        let data = snapshot.data() ?? [:]

        guard
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
        self.title = title
        self.city = city
        self.placeName = placeName
        self.description = description
        self.phone = phone
        self.date = dateTS.dateValue()
        self.createdAt = createdTS.dateValue()
    }
}

/// خدمة التعامل مع Firestore لإعلانات الفعاليات
final class EventAdsService {

    static let shared = EventAdsService()

    private let db = Firestore.firestore()
    private let collectionName = "cityEventAds"

    private init() {}

    /// الاستماع للفعاليات (من اليوم وما بعده) بترتيب التاريخ
    @discardableResult
    func observeUpcomingEvents(
        completion: @escaping (Result<[EventAd], Error>) -> Void
    ) -> ListenerRegistration {
        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayTS = Timestamp(date: todayStart)

        return db.collection(collectionName)
            .whereField("date", isGreaterThanOrEqualTo: todayTS)
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let docs = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

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
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let data: [String: Any] = [
            "title": title,
            "city": city,
            "placeName": placeName,
            "date": Timestamp(date: date),
            "description": description,
            "phone": phone,
            "createdAt": Timestamp(date: Date())
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

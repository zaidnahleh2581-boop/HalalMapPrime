import Foundation
import FirebaseFirestore
import Combine
// MARK: - موديل إعلان المجتمع المجاني

struct CommunityAd: Identifiable {
    let id: String
    let fullName: String
    let phone: String
    let email: String
    let title: String
    let details: String
    let city: String
    let category: String
    let createdAt: Date?

    init?(from doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        guard
            let fullName = data["fullName"] as? String,
            let phone = data["phone"] as? String,
            let title = data["title"] as? String,
            let details = data["details"] as? String,
            let city = data["city"] as? String,
            let category = data["category"] as? String
        else {
            return nil
        }

        self.id = doc.documentID
        self.fullName = fullName
        self.phone = phone
        self.email = data["email"] as? String ?? ""
        self.title = title
        self.details = details
        self.city = city
        self.category = category

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }
    }
}

// MARK: - ViewModel لإعلانات المجتمع (تظهر في "إعلاناتي")

final class CommunityAdsViewModel: ObservableObject {

    @Published var myAds: [CommunityAd] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// ownerPhone: تقدر تحط رقم هاتف المستخدم الحالي عشان يشوف إعلاناته فقط
    init(ownerPhone: String? = nil) {
        DispatchQueue.main.async {
            self.startListening(ownerPhone: ownerPhone)
        }
    }

    deinit {
        listener?.remove()
    }

    private func startListening(ownerPhone: String?) {
        var query: Query = db.collection("communityAds")
            .order(by: "createdAt", descending: true)

        if let phone = ownerPhone, !phone.trimmingCharacters(in: .whitespaces).isEmpty {
            query = query.whereField("phone", isEqualTo: phone)
        }

        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error listening for community ads: \(error.localizedDescription)")
                return
            }

            guard let docs = snapshot?.documents else {
                DispatchQueue.main.async {
                    self.myAds = []
                }
                return
            }

            let ads = docs.compactMap { CommunityAd(from: $0) }

            DispatchQueue.main.async {
                self.myAds = ads
            }
        }
    }
}

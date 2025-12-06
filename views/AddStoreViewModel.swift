import Foundation
import Combine
import FirebaseFirestore

final class AddStoreViewModel: ObservableObject {

    // مدخلات النموذج
    @Published var selectedCategory: PlaceCategory = .restaurant
    @Published var name: String = ""
    @Published var address: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var phone: String = ""
    @Published var website: String = ""
    @Published var notes: String = ""

    // حالة النموذج
    @Published var isSubmitting: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showValidationAlert: Bool = false

    private let db = Firestore.firestore()

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !state.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func submit() {
        guard !isSubmitting else { return }

        guard isFormValid else {
            showValidationAlert = true
            return
        }

        isSubmitting = true

        let cityState = [city, state].filter { !$0.isEmpty }.joined(separator: ", ")

        let data: [String: Any] = [
            "name": name,
            "address": address,
            "city": city,
            "state": state,
            "cityState": cityState,
            "phone": phone,
            "website": website,
            "notes": notes,
            "category": selectedCategory.rawValue,
            "rating": 0.0,
            "reviewCount": 0,
            "deliveryAvailable": false,
            "isCertified": false,
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("places").addDocument(data: data) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSubmitting = false

                if let error = error {
                    print("AddStore error:", error)
                    self.showValidationAlert = true
                } else {
                    self.showSuccessAlert = true
                    self.resetForm()
                }
            }
        }
    }

    private func resetForm() {
        selectedCategory = .restaurant
        name = ""
        address = ""
        city = ""
        state = ""
        phone = ""
        website = ""
        notes = ""
    }
}

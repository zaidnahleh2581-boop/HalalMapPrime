import SwiftUI

struct EventAdComposerView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var city: String = ""
    @State private var placeName: String = ""
    @State private var date: Date = Date()
    @State private var description: String = ""
    @State private var phone: String = ""

    @State private var isSaving: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    private var minDate: Date {
        Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date()
    }

    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text(lang.isArabic ? "معلومات الفعالية" : "Event info")) {
                    TextField(
                        lang.isArabic ? "عنوان الفعالية (مثال: بازار رمضان)" : "Event title (e.g. Ramadan Bazaar)",
                        text: $title
                    )

                    TextField(
                        lang.isArabic ? "المدينة / المنطقة" : "City / area",
                        text: $city
                    )

                    TextField(
                        lang.isArabic ? "اسم المكان (مسجد / مركز / قاعة)" : "Place name (masjid / center / hall)",
                        text: $placeName
                    )

                    DatePicker(
                        lang.isArabic ? "تاريخ الفعالية" : "Event date",
                        selection: $date,
                        in: minDate...,
                        displayedComponents: .date
                    )
                }

                Section(header: Text(lang.isArabic ? "وصف الفعالية" : "Event description")) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $description)
                            .frame(minHeight: 120)

                        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(
                                lang.isArabic
                                ? "مثال: بازار في مسجد كذا، يوجد أطعمة حلال ومحاضرات، من الساعة ٥ حتى ٩ مساءً."
                                : "Example: Bazaar at XYZ Masjid, halal food and lectures, from 5 PM to 9 PM."
                            )
                            .foregroundColor(.secondary.opacity(0.7))
                            .padding(.top, 8)
                            .padding(.horizontal, 5)
                            .allowsHitTesting(false)
                        }
                    }
                }

                Section(header: Text(lang.isArabic ? "معلومات التواصل" : "Contact info")) {
                    TextField(
                        lang.isArabic ? "رقم الهاتف" : "Phone number",
                        text: $phone
                    )
                    .keyboardType(.phonePad)
                }

                Section {
                    Button {
                        saveEvent()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text(lang.isArabic ? "نشر إعلان الفعالية" : "Publish event ad")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle(
                lang.isArabic ? "إعلان فعالية" : "City event ad"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text(lang.isArabic ? "خطأ" : "Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text(lang.isArabic ? "حسناً" : "OK"))
                )
            }
        }
    }

    // MARK: - حفظ الفعالية

    private func saveEvent() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !city.trimmingCharacters(in: .whitespaces).isEmpty,
              !placeName.trimmingCharacters(in: .whitespaces).isEmpty,
              !phone.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = lang.isArabic
            ? "الرجاء تعبئة عنوان الفعالية والمدينة واسم المكان ورقم الهاتف."
            : "Please fill in event title, city, place name and phone."
            showErrorAlert = true
            return
        }

        isSaving = true

        EventAdsService.shared.createEventAd(
            title: title,
            city: city,
            placeName: placeName,
            date: date,
            description: description,
            phone: phone
        ) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

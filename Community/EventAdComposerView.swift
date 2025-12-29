import SwiftUI

struct EventAdComposerView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // ✅ لو nil = Create، لو موجود = Edit
    let editingAd: EventAd?

    @State private var title: String = ""
    @State private var city: String = ""
    @State private var placeName: String = ""
    @State private var date: Date = Date()
    @State private var selectedTemplate: EventTemplate = .communityMeeting
    @State private var phone: String = ""

    @State private var isSaving: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    init(editingAd: EventAd? = nil) {
        self.editingAd = editingAd
    }

    private var minDate: Date {
        Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date()
    }

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private var dateText: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }

    private var templatePreview: String {
        selectedTemplate.text(
            isArabic: lang.isArabic,
            city: city.trimmingCharacters(in: .whitespaces),
            place: placeName.trimmingCharacters(in: .whitespaces),
            dateText: dateText,
            phone: phone.trimmingCharacters(in: .whitespaces)
        )
    }

    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text(L("معلومات الفعالية", "Event info"))) {
                    TextField(L("عنوان الفعالية", "Event title"), text: $title)
                    TextField(L("المدينة / المنطقة (NY/NJ)", "City / area (NY/NJ)"), text: $city)
                    TextField(L("اسم المكان (مسجد / مركز / قاعة)", "Place name (masjid / center / hall)"), text: $placeName)

                    DatePicker(
                        L("تاريخ الفعالية", "Event date"),
                        selection: $date,
                        in: minDate...,
                        displayedComponents: .date
                    )
                }

                Section(header: Text(L("اختر صيغة جاهزة", "Choose a ready template"))) {
                    Picker(L("القالب", "Template"), selection: $selectedTemplate) {
                        ForEach(EventTemplate.allCases) { t in
                            Text(lang.isArabic ? t.displayTitle.ar : t.displayTitle.en)
                                .tag(t)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(L("المعاينة", "Preview"))
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.secondary)

                        Text(templatePreview.isEmpty ? L("املأ الحقول لإظهار المعاينة.", "Fill fields to see preview.") : templatePreview)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 6)
                }

                Section(header: Text(L("معلومات التواصل", "Contact info"))) {
                    TextField(L("رقم الهاتف", "Phone number"), text: $phone)
                        .keyboardType(.phonePad)
                }

                Section {
                    Button {
                        save()
                    } label: {
                        if isSaving {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text(editingAd == nil ? L("نشر الفعالية", "Publish event") : L("حفظ التعديل", "Save changes"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle(editingAd == nil ? L("إضافة فعالية", "Add event") : L("تعديل فعالية", "Edit event"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").imageScale(.medium)
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text(L("خطأ", "Error")),
                    message: Text(errorMessage),
                    dismissButton: .default(Text(L("حسناً", "OK")))
                )
            }
            .onAppear {
                // ✅ Prefill لو Edit
                if let ad = editingAd {
                    title = ad.title
                    city = ad.city
                    placeName = ad.placeName
                    date = ad.date
                    phone = ad.phone
                    selectedTemplate = EventTemplate(rawValue: ad.templateId) ?? .communityMeeting
                }
            }
        }
    }

    private func save() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !city.trimmingCharacters(in: .whitespaces).isEmpty,
              !placeName.trimmingCharacters(in: .whitespaces).isEmpty,
              !phone.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = L(
                "الرجاء تعبئة: العنوان، المدينة، اسم المكان، رقم الهاتف.",
                "Please fill: title, city, place name, phone."
            )
            showErrorAlert = true
            return
        }

        isSaving = true

        if let ad = editingAd {
            EventAdsService.shared.updateEventAd(
                adId: ad.id,
                title: title,
                city: city,
                placeName: placeName,
                date: date,
                description: templatePreview,
                phone: phone,
                templateId: selectedTemplate.rawValue
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
        } else {
            EventAdsService.shared.createEventAd(
                title: title,
                city: city,
                placeName: placeName,
                date: date,
                description: templatePreview,
                phone: phone,
                templateId: selectedTemplate.rawValue
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
}

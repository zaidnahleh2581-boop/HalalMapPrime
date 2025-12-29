//
//  jobLegacyBoard.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-29.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import Combine

// MARK: - أنواع الإعلانات (أبحث عن عمل / أبحث عن موظف)

enum JobAdType: String, CaseIterable {
    case lookingForJob   // أبحث عن عمل
    case hiring          // أبحث عن موظف
}

// فلتر أعلى شاشة الإعلانات
enum JobAdFilter: String, CaseIterable {
    case all
    case lookingForJob
    case hiring
}

// MARK: - موديل إعلان الوظيفة القادم من Firebase

struct JobAd: Identifiable {
    let id: String
    let type: JobAdType
    let text: String
    let city: String
    let category: String
    let phone: String
    let createdAt: Date?

    init?(from doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        guard
            let typeRaw = data["type"] as? String,
            let type = JobAdType(rawValue: typeRaw),
            let text = data["text"] as? String
        else {
            return nil
        }

        self.id = doc.documentID
        self.type = type
        self.text = text
        self.city = data["city"] as? String ?? ""
        self.category = data["category"] as? String ?? ""
        self.phone = data["phone"] as? String ?? ""

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }
    }
}

// MARK: - ViewModel لعرض الإعلانات من Firebase

final class JobAdsBoardViewModel: ObservableObject {

    @Published var jobAds: [JobAd] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        DispatchQueue.main.async { [weak self] in
            self?.startListening()
        }
    }

    deinit {
        listener?.remove()
    }

    /// الاستماع من مجموعة jobAds مع فلترة الإعلانات الأقدم من ٧ أيام
    private func startListening() {
        listener = db.collection("jobAds")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error listening for job ads: \(error.localizedDescription)")
                    return
                }

                guard let docs = snapshot?.documents else {
                    DispatchQueue.main.async { self.jobAds = [] }
                    return
                }

                let now = Date()
                let maxAge: TimeInterval = 7 * 24 * 60 * 60

                let ads = docs
                    .compactMap { JobAd(from: $0) }
                    .filter { ad in
                        guard let created = ad.createdAt else { return true }
                        return now.timeIntervalSince(created) <= maxAge
                    }

                DispatchQueue.main.async {
                    self.jobAds = ads
                }
            }
    }
}

// MARK: - شاشة إنشاء إعلان وظيفة (جمل جاهزة + حفظ في Firebase)

struct JobAdComposerView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var adType: JobAdType = .lookingForJob
    @State private var name: String = ""
    @State private var city: String = ""
    @State private var phone: String = ""
    @State private var selectedCategory: String = ""

    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?

    private let db = Firestore.firestore()

    private var categoriesAr: [String] = [
        "مسجد",
        "مطعم",
        "محل تجاري",
        "سوبرماركت",
        "محل ملابس",
        "صالون حلاقة",
        "مخبز",
        "مكتب خدمات",
        "محل بقالة"
    ]

    private var categoriesEn: [String] = [
        "Masjid",
        "Restaurant",
        "Store",
        "Supermarket",
        "Clothing store",
        "Barber shop",
        "Bakery",
        "Office",
        "Grocery store"
    ]

    private var categories: [String] { lang.isArabic ? categoriesAr : categoriesEn }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private var generatedText: String {
        let safeName = name.isEmpty ? (lang.isArabic ? "الاسم" : "Name") : name
        let safeCity = city.isEmpty ? (lang.isArabic ? "المدينة" : "City") : city
        let safePhone = phone.isEmpty ? (lang.isArabic ? "رقم الهاتف" : "Phone") : phone
        let safeCategory = selectedCategory.isEmpty ? (lang.isArabic ? "محل تجاري" : "store") : selectedCategory

        if lang.isArabic {
            switch adType {
            case .lookingForJob:
                return "أنا \(safeName) أبحث عن عمل في \(safeCity) في \(safeCategory). رقم التواصل: \(safePhone)"
            case .hiring:
                return "أنا \(safeName) صاحب \(safeCategory) في \(safeCity) وأبحث عن موظف. رقم التواصل: \(safePhone)"
            }
        } else {
            switch adType {
            case .lookingForJob:
                return "My name is \(safeName). I am looking for a job in \(safeCity) in a \(safeCategory). Phone: \(safePhone)"
            case .hiring:
                return "My name is \(safeName). I own a \(safeCategory) in \(safeCity) and I am looking for an employee. Phone: \(safePhone)"
            }
        }
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedCategory.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text(L("نوع الإعلان", "Ad type"))) {
                    Picker("", selection: $adType) {
                        Text(L("أبحث عن عمل", "Looking for a job"))
                            .tag(JobAdType.lookingForJob)
                        Text(L("أبحث عن موظف", "Looking for an employee"))
                            .tag(JobAdType.hiring)
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text(L("البيانات الأساسية", "Basic info"))) {
                    TextField(L("الاسم (مثال: محمد)", "Name (e.g. Mohamed)"), text: $name)

                    TextField(
                        L("المنطقة / المدينة (مثال: أستوريا، بروكلين)", "Area / city (e.g. Astoria, Brooklyn)"),
                        text: $city
                    )

                    TextField(L("رقم الهاتف", "Phone number"), text: $phone)
                        .keyboardType(.phonePad)
                }

                Section(header: Text(L("نوع المكان", "Place type"))) {
                    Picker(L("اختر المجال", "Select category"), selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Section(header: Text(L("نص الإعلان النهائي", "Final ad text"))) {
                    Text(generatedText)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }

                Section {
                    Button {
                        submitToFirebase()
                    } label: {
                        HStack {
                            if isSubmitting { ProgressView() }
                            Text(L("نشر الإعلان", "Publish ad"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(L("إعلان وظائف", "Job ad"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").imageScale(.medium)
                    }
                }
            }
        }
    }

    private func submitToFirebase() {
        guard isFormValid else { return }

        isSubmitting = true
        errorMessage = nil

        let data: [String: Any] = [
            "type"      : adType.rawValue,
            "text"      : generatedText,
            "city"      : city.trimmingCharacters(in: .whitespaces),
            "category"  : selectedCategory,
            "phone"     : phone.trimmingCharacters(in: .whitespaces),
            "createdAt" : FieldValue.serverTimestamp()
        ]

        db.collection("jobAds").addDocument(data: data) { error in
            DispatchQueue.main.async {
                self.isSubmitting = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.dismiss()
                }
            }
        }
    }
}

// MARK: - شاشة عرض إعلانات الوظائف (القديمة الواضحة)

struct JobAdsBoardView: View {

    @EnvironmentObject var lang: LanguageManager

    @StateObject private var viewModel = JobAdsBoardViewModel()
    @State private var showComposer: Bool = false
    @State private var selectedFilter: JobAdFilter = .all

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private var filteredAds: [JobAd] {
        viewModel.jobAds.filter { ad in
            switch selectedFilter {
            case .all: return true
            case .lookingForJob: return ad.type == .lookingForJob
            case .hiring: return ad.type == .hiring
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(L("إعلانات الوظائف", "Job ads"))) {

                    Picker(L("فلتر", "Filter"), selection: $selectedFilter) {
                        Text(L("الكل", "All")).tag(JobAdFilter.all)
                        Text(L("أبحث عن عمل", "Looking for job")).tag(JobAdFilter.lookingForJob)
                        Text(L("أبحث عن موظف", "Hiring")).tag(JobAdFilter.hiring)
                    }
                    .pickerStyle(.segmented)

                    if filteredAds.isEmpty {
                        Text(L("لا توجد إعلانات حالياً.", "No job ads yet."))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(filteredAds) { ad in
                            jobAdRow(ad)
                        }
                    }
                }
            }
            .navigationTitle(L("وظائف", "Jobs"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showComposer = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                    .accessibilityLabel(L("إضافة إعلان وظيفة", "Add job ad"))
                }
            }
            .sheet(isPresented: $showComposer) {
                JobAdComposerView()
                    .environmentObject(lang)
            }
        }
    }

    @ViewBuilder
    private func jobAdRow(_ ad: JobAd) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(
                ad.type == .lookingForJob
                ? L("أبحث عن عمل", "Looking for a job")
                : L("أبحث عن موظف", "Hiring")
            )
            .font(.headline)

            Text(ad.text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                if !ad.city.isEmpty {
                    Label(ad.city, systemImage: "mappin.and.ellipse")
                }
                Spacer()
                if let created = ad.createdAt {
                    Text(dateFormatter.string(from: created))
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

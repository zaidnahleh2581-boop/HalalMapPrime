//
//  jobLegacyBoard.swift
//  HalalMapPrime
//
//  Polished UI + Owner-only delete (Anonymous Auth)
//  Keeps same core logic (jobAds collection + 7 days filter)
//
//  Created by Zaid Nahleh
//
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
// MARK: - Types

enum JobAdType: String, CaseIterable, Identifiable {
    case lookingForJob
    case hiring
    var id: String { rawValue }
}

// MARK: - Model

struct JobAd: Identifiable {
    let id: String
    let type: JobAdType
    let text: String
    let city: String
    let category: String
    let phone: String
    let createdAt: Date?
    let ownerId: String

    init?(from doc: QueryDocumentSnapshot) {
        let data = doc.data()

        guard
            let typeStr = data["type"] as? String,
            let type = JobAdType(rawValue: typeStr),
            let text = data["text"] as? String,
            let city = data["city"] as? String,
            let category = data["category"] as? String,
            let phone = data["phone"] as? String
        else { return nil }

        self.id = doc.documentID
        self.type = type
        self.text = text
        self.city = city
        self.category = category
        self.phone = phone

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }

        self.ownerId = data["ownerId"] as? String ?? ""
    }
}

// MARK: - ViewModel

@MainActor
final class JobAdsBoardViewModel: ObservableObject {
    @Published var jobAds: [JobAd] = []
    @Published var authReady: Bool = false

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        Task {
            await ensureAnonAuth()
            startListening()
        }
    }

    deinit {
        listener?.remove()
    }

    var currentUid: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    private func ensureAnonAuth() async {
        if Auth.auth().currentUser != nil {
            authReady = true
            return
        }
        do {
            _ = try await Auth.auth().signInAnonymously()
            authReady = true
        } catch {
            print("Anonymous auth failed: \(error.localizedDescription)")
            authReady = false
        }
    }

    /// listen jobAds (last 7 days only)
    private func startListening() {
        listener?.remove()

        listener = db.collection("jobAds")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error = error {
                    print("Error listening for job ads: \(error.localizedDescription)")
                    return
                }

                let docs = snapshot?.documents ?? []
                let now = Date()
                let maxAge: TimeInterval = 7 * 24 * 60 * 60

                let ads = docs
                    .compactMap { JobAd(from: $0) }
                    .filter { ad in
                        guard let created = ad.createdAt else { return true }
                        return now.timeIntervalSince(created) <= maxAge
                    }

                self.jobAds = ads
            }
    }

    func delete(ad: JobAd) async {
        guard !ad.id.isEmpty else { return }
        guard ad.ownerId == currentUid else { return }

        do {
            try await db.collection("jobAds").document(ad.id).delete()
        } catch {
            print("Delete failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Main Board View

struct JobAdsBoardView: View {
    @EnvironmentObject var lang: LanguageManager
    @StateObject private var vm = JobAdsBoardViewModel()

    @State private var showComposer = false
    @State private var query: String = ""
    @State private var filterType: JobAdType? = nil

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private var filtered: [JobAd] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return vm.jobAds.filter { ad in
            let matchesType = (filterType == nil) ? true : (ad.type == filterType)
            let matchesQuery: Bool
            if q.isEmpty {
                matchesQuery = true
            } else {
                matchesQuery =
                    ad.text.lowercased().contains(q) ||
                    ad.city.lowercased().contains(q) ||
                    ad.category.lowercased().contains(q) ||
                    ad.phone.lowercased().contains(q)
            }
            return matchesType && matchesQuery
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 12) {
                    headerControls

                    if filtered.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { ad in
                                    JobAdCardView(
                                        ad: ad,
                                        isArabic: lang.isArabic,
                                        canDelete: (ad.ownerId == vm.currentUid),
                                        onDelete: {
                                            Task { await vm.delete(ad: ad) }
                                        }
                                    )
                                    .padding(.horizontal, 14)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle(L("الوظائف", "Jobs"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showComposer = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel(L("إضافة إعلان", "Add Ad"))
                }
            }
            .sheet(isPresented: $showComposer) {
                JobAdComposerView()
                    .environmentObject(lang)
            }
        }
    }

    private var headerControls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField(L("ابحث (مدينة/تصنيف/نص/هاتف)", "Search (city/category/text/phone)"), text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 14)
            .padding(.top, 10)

            HStack(spacing: 10) {
                filterChip(title: L("الكل", "All"), isOn: filterType == nil) {
                    filterType = nil
                }
                filterChip(title: L("أبحث عن عمل", "Looking"), isOn: filterType == .lookingForJob) {
                    filterType = .lookingForJob
                }
                filterChip(title: L("أبحث عن موظف", "Hiring"), isOn: filterType == .hiring) {
                    filterType = .hiring
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private func filterChip(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(isOn ? Color.blue.opacity(0.18) : Color.secondary.opacity(0.10))
                .foregroundColor(isOn ? .blue : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "briefcase.fill")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text(L("لا يوجد إعلانات حالياً", "No ads right now"))
                .font(.headline)
            Text(L("اضغط + لإضافة إعلان جديد.", "Tap + to add a new ad."))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
    }
}

// MARK: - Card View

private struct JobAdCardView: View {
    let ad: JobAd
    let isArabic: Bool
    let canDelete: Bool
    let onDelete: () -> Void

    private func L(_ ar: String, _ en: String) -> String { isArabic ? ar : en }

    private var typeTitle: String {
        switch ad.type {
        case .lookingForJob: return L("أبحث عن عمل", "Looking for job")
        case .hiring: return L("أبحث عن موظف", "Hiring")
        }
    }

    private var typeIcon: String {
        switch ad.type {
        case .lookingForJob: return "person.fill"
        case .hiring: return "person.badge.plus"
        }
    }

    private var phoneURL: URL? {
        let cleaned = ad.phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        return URL(string: "tel://\(cleaned)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                HStack(spacing: 8) {
                    Image(systemName: typeIcon)
                        .foregroundColor(.blue)
                    Text(typeTitle)
                        .font(.headline)
                }
                Spacer()
                if let d = ad.createdAt {
                    Text(d.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(ad.text)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                badge(icon: "mappin.and.ellipse", text: ad.city)
                badge(icon: "tag.fill", text: ad.category)
            }

            HStack(spacing: 10) {
                if let phoneURL {
                    Link(destination: phoneURL) {
                        HStack(spacing: 8) {
                            Image(systemName: "phone.fill")
                            Text(ad.phone)
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.18))
                        .foregroundColor(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                        Text(ad.phone)
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.12))
                    .foregroundColor(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if canDelete {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                            Text(L("حذف", "Delete"))
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.14))
                        .foregroundColor(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }

            if canDelete {
                Text(L("هذا إعلانك — يمكنك حذفه.", "This is your ad — you can delete it."))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .contextMenu {
            if canDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label(L("حذف الإعلان", "Delete Ad"), systemImage: "trash")
                }
            }
        }
    }

    private func badge(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.caption)
            Text(text).font(.caption.weight(.semibold))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.secondary.opacity(0.12))
        .foregroundColor(.secondary)
        .clipShape(Capsule())
    }
}

// MARK: - Composer

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

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private var categoriesAr: [String] = [
        "مسجد", "مطعم", "محل تجاري", "سوبرماركت", "محل ملابس", "صالون حلاقة", "مخبز", "مكتب خدمات", "محل بقالة"
    ]

    private var categoriesEn: [String] = [
        "Masjid", "Restaurant", "Store", "Supermarket", "Clothing store", "Barber shop", "Bakery", "Office", "Grocery store"
    ]

    private var categories: [String] { lang.isArabic ? categoriesAr : categoriesEn }

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
                return "I’m \(safeName) looking for a job in \(safeCity) in \(safeCategory). Contact: \(safePhone)"
            case .hiring:
                return "I’m \(safeName), owner of a \(safeCategory) in \(safeCity) and hiring. Contact: \(safePhone)"
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        pickerCard
                        fieldsCard
                        previewCard

                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.horizontal, 16)
                        }

                        Button {
                            Task { await submit() }
                        } label: {
                            HStack {
                                if isSubmitting { ProgressView().padding(.trailing, 6) }
                                Text(L("نشر الإعلان", "Post Ad"))
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(isSubmitting)
                        .padding(.horizontal, 16)
                        .padding(.top, 6)

                        Text(L("سيتم حذف الإعلانات تلقائياً من العرض بعد ٧ أيام.", "Ads auto-hide after 7 days."))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle(L("إضافة إعلان وظيفة", "Create Job Ad"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L("إغلاق", "Close")) { dismiss() }
                }
            }
        }
    }

    private var pickerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("نوع الإعلان", "Ad Type"))
                .font(.headline)

            Picker("", selection: $adType) {
                Text(L("أبحث عن عمل", "Looking for Job")).tag(JobAdType.lookingForJob)
                Text(L("أبحث عن موظف", "Hiring")).tag(JobAdType.hiring)
            }
            .pickerStyle(.segmented)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 14)
    }

    private var fieldsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L("المعلومات", "Details"))
                .font(.headline)

            field(title: L("الاسم", "Name"), text: $name)
            field(title: L("المدينة", "City"), text: $city)
            field(title: L("رقم الهاتف", "Phone"), text: $phone, keyboard: .phonePad)

            VStack(alignment: .leading, spacing: 8) {
                Text(L("التصنيف", "Category"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Menu {
                    ForEach(categories, id: \.self) { c in
                        Button(c) { selectedCategory = c }
                    }
                } label: {
                    HStack {
                        Text(selectedCategory.isEmpty ? L("اختر التصنيف", "Choose category") : selectedCategory)
                            .foregroundColor(selectedCategory.isEmpty ? .secondary : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color.secondary.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 14)
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("معاينة الإعلان", "Preview"))
                .font(.headline)

            Text(generatedText)
                .font(.subheadline)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 14)
    }

    private func field(title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField(title, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.words)
                .padding(12)
                .background(Color.secondary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func ensureAnonAuthIfNeeded() async throws {
        if Auth.auth().currentUser != nil { return }
        _ = try await Auth.auth().signInAnonymously()
    }

    private func submit() async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await ensureAnonAuthIfNeeded()

            let uid = Auth.auth().currentUser?.uid ?? ""

            let doc: [String: Any] = [
                "type": adType.rawValue,
                "text": generatedText,
                "city": city.isEmpty ? "-" : city,
                "category": selectedCategory.isEmpty ? (lang.isArabic ? "محل تجاري" : "Store") : selectedCategory,
                "phone": phone.isEmpty ? "-" : phone,
                "createdAt": FieldValue.serverTimestamp(),
                "ownerId": uid
            ]

            _ = try await db.collection("jobAds").addDocument(data: doc)
            dismiss()
        } catch {
            errorMessage = L("حصل خطأ أثناء النشر. حاول مرة ثانية.", "Failed to post. Please try again.")
            print("Submit job ad failed: \(error.localizedDescription)")
        }
    }
}

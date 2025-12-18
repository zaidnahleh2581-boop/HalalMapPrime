//
//  FreeAdFormView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//  Updated by Zaid Nahleh on 12/18/25.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct FreeAdFormView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var businessName: String = ""
    @State private var ownerName: String = ""
    @State private var phone: String = ""
    @State private var addressLine: String = ""
    @State private var city: String = ""
    @State private var state: String = ""

    @State private var isPublishing = false

    @State private var businessType: Ad.BusinessType = .restaurant
    @State private var template: Ad.CopyTemplate = .simple

    // Optional placeId (but validated)
    @State private var placeIdOptional: String = ""

    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var pickedImages: [UIImage] = []

    @State private var showSavedAlert = false
    @State private var errorMessage: String? = nil

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text(L("بيانات المحل", "Business info"))) {
                    TextField(L("اسم المحل", "Business name"), text: $businessName)
                    TextField(L("اسم صاحب المحل", "Owner name"), text: $ownerName)

                    TextField(L("رقم الهاتف", "Phone number"), text: $phone)
                        .keyboardType(.phonePad)

                    TextField(L("العنوان", "Address"), text: $addressLine)

                    HStack {
                        TextField(L("المدينة", "City"), text: $city)
                        TextField(L("الولاية", "State"), text: $state)
                            .frame(width: 80)
                            .textInputAutocapitalization(.characters)
                    }
                }

                Section(header: Text(L("نوع النشاط", "Business type"))) {
                    Picker(L("اختر النوع", "Select type"), selection: $businessType) {
                        ForEach(Ad.BusinessType.allCases) { t in
                            Text(lang.isArabic ? t.titleAR : t.titleEN).tag(t)
                        }
                    }
                }

                Section(header: Text(L("قالب الإعلان", "Ad template"))) {
                    Picker(L("اختر قالب", "Choose template"), selection: $template) {
                        ForEach(Ad.CopyTemplate.allCases) { t in
                            Text(lang.isArabic ? t.titleAR : t.titleEN).tag(t)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L("معاينة النص (من النظام)", "Copy preview (system-generated)"))
                            .font(.footnote.bold())
                        Text(previewCopy())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                Section(header: Text(L("صور الإعلان (1–3)", "Ad images (1–3)"))) {
                    PhotosPicker(selection: $pickedItems, maxSelectionCount: 3, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text(L("اختر صور", "Pick photos"))
                            Spacer()
                        }
                    }
                    .onChange(of: pickedItems) { newItems in
                        Task { await loadImages(from: newItems) }
                    }

                    if pickedImages.isEmpty {
                        Text(L("لم يتم اختيار صور بعد.", "No images selected yet."))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(pickedImages.enumerated()), id: \.offset) { _, img in
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 90)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section(header: Text(L("ربط الإعلان (اختياري)", "Linking (optional)"))) {
                    TextField(L("Place ID (اختياري)", "Place ID (optional)"), text: $placeIdOptional)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text(L(
                        "إذا كتبت Place ID لازم يكون موجود فعلاً في Firebase/places، وإلا سيتم رفض النشر. (هذا يمنع التلاعب)",
                        "If you enter Place ID, it must exist in Firebase/places, otherwise publish is rejected (anti-abuse)."
                    ))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }

                Section(header: Text(L("مدة الإعلان", "Ad duration"))) {
                    Text(L("إعلان مجاني لمدة 14 يوم، وبعدها يختفي.", "Free ad lasts 14 days, then it disappears."))
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Text(L("يمكنك نشر إعلان مجاني مرة واحدة بالشهر.", "You can publish one free ad per month."))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                if let errorMessage {
                    Section { Text(errorMessage).foregroundColor(.red).font(.footnote) }
                }
            }
            .navigationTitle(L("إعلان مجاني", "Free Ad"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("إغلاق", "Close")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("نشر", "Publish")) { publish() }
                        .disabled(isPublishing)
                }
            }
            .alert(L("تم", "Saved"), isPresented: $showSavedAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(L("تم نشر الإعلان لمدة 14 يوم.", "Your ad is published for 14 days."))
            }
        }
    }

    private func previewCopy() -> String {
        let b = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        let o = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let ph = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let addr = addressLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let st = state.trimmingCharacters(in: .whitespacesAndNewlines)

        let temp = Ad(
            tier: .free,
            status: .active,
            placeId: nil,
            imagePaths: [],
            businessName: b.isEmpty ? L("اسم المحل", "Business name") : b,
            ownerName: o.isEmpty ? L("صاحب المحل", "Owner") : o,
            phone: ph.isEmpty ? "000-000-0000" : ph,
            addressLine: addr.isEmpty ? L("العنوان", "Address") : addr,
            city: c.isEmpty ? L("المدينة", "City") : c,
            state: st.isEmpty ? "NY" : st,
            businessType: businessType,
            template: template,
            createdAt: Date(),
            expiresAt: Date().addingTimeInterval(14 * 24 * 60 * 60),
            freeCooldownKey: ph.isEmpty ? "temp" : ph
        )

        return AdCopyLibrary.generate(ad: temp, isArabic: lang.isArabic)
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        await MainActor.run {
            pickedImages.removeAll()
            errorMessage = nil
        }

        var imgs: [UIImage] = []
        for item in items.prefix(3) {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                imgs.append(img)
            }
        }

        await MainActor.run { pickedImages = imgs }
    }

    private func publish() {
        errorMessage = nil

        let bName = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        let oName = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let ph = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let addr = addressLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let st = state.trimmingCharacters(in: .whitespacesAndNewlines)
        let pid = placeIdOptional.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !bName.isEmpty else { errorMessage = L("اسم المحل مطلوب.", "Business name is required."); return }
        guard !oName.isEmpty else { errorMessage = L("اسم صاحب المحل مطلوب.", "Owner name is required."); return }
        guard !ph.isEmpty else { errorMessage = L("رقم الهاتف مطلوب.", "Phone is required."); return }
        guard !addr.isEmpty else { errorMessage = L("العنوان مطلوب.", "Address is required."); return }
        guard !c.isEmpty else { errorMessage = L("المدينة مطلوبة.", "City is required."); return }
        guard !st.isEmpty else { errorMessage = L("الولاية مطلوبة.", "State is required."); return }

        guard (1...3).contains(pickedImages.count) else {
            errorMessage = L("اختَر 1 إلى 3 صور.", "Pick 1 to 3 images.")
            return
        }

        isPublishing = true

        Task {
            do {
                let uid = try await AuthManager.shared.ensureSignedIn()

                // ✅ validate placeId if provided
                if !pid.isEmpty {
                    let exists = try await placeExists(placeId: pid)
                    if !exists {
                        await MainActor.run {
                            self.isPublishing = false
                            self.errorMessage = self.L(
                                "Place ID غير موجود في Firebase/places. امسحه أو اختر ID صحيح.",
                                "Place ID does not exist in Firebase/places. Remove it or use a valid ID."
                            )
                        }
                        return
                    }
                }

                // cooldown check
                let cooldown = try await canPostFreeAd(phone: ph)
                if !cooldown.allowed {
                    await MainActor.run {
                        self.errorMessage = self.L(
                            "لا يمكنك نشر إعلان مجاني الآن. حاول بعد \(cooldown.remainingDays) يوم.",
                            "You can’t post a free ad now. Try again in \(cooldown.remainingDays) days."
                        )
                        self.isPublishing = false
                    }
                    return
                }

                let imageURLs = try await uploadImagesToFirebase(uid: uid, phone: ph, images: pickedImages)
                let expires = Date().addingTimeInterval(14 * 24 * 60 * 60)

                var adData: [String: Any] = [
                    "tier": "free",
                    "status": "active",
                    "ownerId": uid,

                    "businessName": bName,
                    "ownerName": oName,
                    "phone": ph,
                    "addressLine": addr,
                    "city": c,
                    "state": st,

                    "businessType": businessType.rawValue,
                    "template": template.rawValue,

                    "imageURLs": imageURLs,
                    "createdAt": Timestamp(date: Date()),
                    "expiresAt": Timestamp(date: expires),

                    "isActive": true,
                    "freeCooldownKey": ph
                ]

                if !pid.isEmpty { adData["placeId"] = pid }

                try await Firestore.firestore().collection("ads").addDocument(data: adData)

                await MainActor.run {
                    self.isPublishing = false
                    self.showSavedAlert = true
                }

            } catch {
                print("❌ Publish error:", error) // مهم للتشخيص
                await MainActor.run {
                    self.isPublishing = false
                    self.errorMessage = self.L(
                        "حصل خطأ أثناء النشر: \(error.localizedDescription)",
                        "Publish failed: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    private func placeExists(placeId: String) async throws -> Bool {
        let doc = try await Firestore.firestore().collection("places").document(placeId).getDocument()
        return doc.exists
    }

    private struct CooldownResult {
        let allowed: Bool
        let remainingDays: Int
    }

    private func canPostFreeAd(phone: String) async throws -> CooldownResult {
        let db = Firestore.firestore()
        let now = Date()
        let cutoff = now.addingTimeInterval(-30 * 24 * 60 * 60)

        let snap = try await db.collection("ads")
            .whereField("tier", isEqualTo: "free")
            .whereField("freeCooldownKey", isEqualTo: phone)
            .whereField("createdAt", isGreaterThan: Timestamp(date: cutoff))
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
            .getDocuments()

        guard let doc = snap.documents.first,
              let createdAt = (doc.data()["createdAt"] as? Timestamp)?.dateValue()
        else {
            return CooldownResult(allowed: true, remainingDays: 0)
        }

        let daysPassed = Calendar.current.dateComponents([.day], from: createdAt, to: now).day ?? 0
        let remaining = max(0, 30 - daysPassed)
        return CooldownResult(allowed: remaining == 0, remainingDays: remaining)
    }

    private func uploadImagesToFirebase(uid: String, phone: String, images: [UIImage]) async throws -> [String] {
        let storage = Storage.storage()
        let root = storage.reference().child("ads").child(uid).child(phone).child(UUID().uuidString)

        var urls: [String] = []
        urls.reserveCapacity(images.count)

        for (index, img) in images.enumerated() {
            guard let data = img.jpegData(compressionQuality: 0.82) else { continue }
            let ref = root.child("img_\(index).jpg")
            _ = try await ref.putDataAsync(data, metadata: nil)
            let url = try await ref.downloadURL()
            urls.append(url.absoluteString)
        }

        if urls.isEmpty {
            throw NSError(domain: "Upload", code: 0, userInfo: [NSLocalizedDescriptionKey: "No images uploaded"])
        }
        return urls
    }
}

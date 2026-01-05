
//
//  FreeMonthlyAdFormView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

struct FreeMonthlyAdFormView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @StateObject private var freeStore = FreeAdStateStore()

    // Form
    @State private var businessName: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var phone: String = ""
    @State private var shortText: String = ""   // <= 150 chars

    // Images (local for now)
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var imagesData: [Data] = [] // up to 3

    // UI
    @State private var isSubmitting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    private let db = Firestore.firestore()

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
    private var remainingChars: Int { max(0, 150 - shortText.count) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                headerCard

                if case .alreadyUsed = freeStore.state {
                    usedCard
                } else {
                    formCard
                }
            }
            .padding()
        }
        .navigationTitle(L("إعلان مجاني 30 يوم", "Free Ad (30 days)"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { freeStore.refresh() }
        .onChange(of: photoItems) { _ in
            Task { await loadSelectedPhotos() }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: { Text(alertMessage) }
    }

    // MARK: - UI

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("🎁 إعلان مجاني لمدة 30 يوم", "🎁 Free ad for 30 days"))
                .font(.title3.bold())

            Text(L(
                "أضف صور + وصف مختصر (150 حرف). الإعلان هدفه يجذب المستخدمين لنشاطك.",
                "Add photos + short text (150 chars). The goal is to attract users to your business."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBG)
    }

    private var usedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("✅ تم استخدام الإعلان المجاني لهذا الشهر", "✅ Free ad already used this month"))
                .font(.headline)

            Text(L(
                "تقدر تكمل عبر الإعلانات المدفوعة من صفحة Ads.",
                "You can continue via Paid Ads from the Ads page."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBG)
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Group {
                TextField(L("اسم المحل", "Business name"), text: $businessName)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    TextField(L("المدينة", "City"), text: $city)
                        .textFieldStyle(.roundedBorder)

                    TextField(L("الولاية", "State"), text: $state)
                        .textFieldStyle(.roundedBorder)
                }

                TextField(L("الهاتف (اختياري)", "Phone (optional)"), text: $phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(L("نص الإعلان (حد أقصى 150 حرف)", "Ad text (max 150 chars)"))
                    .font(.headline)

                TextField(
                    L("مثال: خصم 10% اليوم — أفضل شاورما في ستاتن آيلاند!", "Example: 10% off today — best shawarma in Staten Island!"),
                    text: Binding(
                        get: { shortText },
                        set: { newValue in
                            shortText = String(newValue.prefix(150))
                        }
                    ),
                    axis: .vertical
                )
                .lineLimit(3...5)
                .textFieldStyle(.roundedBorder)

                Text(L("متبقي: \(remainingChars) حرف", "Remaining: \(remainingChars) chars"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(L("صور المحل (حتى 3)", "Business photos (up to 3)"))
                    .font(.headline)

                PhotosPicker(
                    selection: $photoItems,
                    maxSelectionCount: 3,
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text(L("اختيار الصور", "Pick photos"))
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                if !imagesData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(imagesData.enumerated()), id: \.offset) { _, data in
                                if let ui = UIImage(data: data) {
                                    Image(uiImage: ui)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 96, height: 72)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                            }
                        }
                    }
                } else {
                    Text(L("لم يتم اختيار صور بعد.", "No photos selected yet."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button {
                Task { await submitFreeAd() }
            } label: {
                HStack {
                    Spacer()
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text(L("نشر الإعلان المجاني", "Publish free ad"))
                            .font(.subheadline.weight(.semibold))
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.92))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isSubmitting)
        }
        .padding()
        .background(cardBG)
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    // MARK: - Photos
    private func loadSelectedPhotos() async {
        imagesData = []
        for item in photoItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
                imagesData.append(data)
            }
        }
    }

    // MARK: - Submit
    private func submitFreeAd() async {
        let n = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let s = state.trimmingCharacters(in: .whitespacesAndNewlines)
        let t = shortText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !n.isEmpty, !c.isEmpty, !s.isEmpty, !t.isEmpty else {
            alertTitle = L("نقص بيانات", "Missing info")
            alertMessage = L("رجاءً عبّي اسم المحل والمدينة والولاية ونص الإعلان.", "Please fill name, city, state, and ad text.")
            showAlert = true
            return
        }

        // Gate check
        if case .alreadyUsed = freeStore.state {
            alertTitle = L("مستخدم", "Already used")
            alertMessage = L("تم استخدام الإعلان المجاني لهذا الشهر.", "This month's free ad is already used.")
            showAlert = true
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let uid = try await ensureUID()
            let now = Date()
            let end = Calendar.current.date(byAdding: .day, value: 30, to: now)

            // NOTE: images are not uploaded yet (MVP). We just store count.
            let payload: [String: Any] = [
                "ownerId": uid,
                "title": n,
                "subtitle": "\(c), \(s)",
                "text": t,                     // <=150 chars enforced
                "phone": phone.trimmingCharacters(in: .whitespacesAndNewlines),
                "imagesCount": imagesData.count,
                "tier": "free",
                "plan": "free_30_days",
                "priceCents": 0,
                "createdAt": FieldValue.serverTimestamp(),
                "startAt": Timestamp(date: now),
                "endAt": end != nil ? Timestamp(date: end!) : NSNull()
            ]

            _ = try await db.collection("cityEventAds").addDocument(data: payload)

            // mark used this month
            try await freeStore.markUsedThisMonth()
            await freeStore.refreshAsync()

            alertTitle = L("تم", "Done")
            alertMessage = L("تم نشر إعلانك المجاني بنجاح.", "Your free ad was published successfully.")
            showAlert = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                dismiss()
            }

        } catch {
            alertTitle = L("خطأ", "Error")
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func ensureUID() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }

        return try await withCheckedThrowingContinuation { cont in
            Auth.auth().signInAnonymously { result, error in
                if let error { cont.resume(throwing: error); return }
                guard let uid = result?.user.uid else {
                    cont.resume(throwing: NSError(domain: "Auth", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Missing UID"
                    ]))
                    return
                }
                cont.resume(returning: uid)
            }
        }
    }
}

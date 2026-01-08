//
//  CreateAdFormView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Updated by Zaid Nahleh on 2026-01-05.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import PhotosUI

struct AdDraft: Equatable {
    var businessName: String = ""
    var headline: String = ""
    var adText: String = ""
    var phone: String = ""
    var website: String = ""
    var addressHint: String = ""
    var selectedAudience: AdAudience = .restaurants

    // ✅ Saved images as Base64
    var imageBase64s: [String] = []
}

struct CreateAdFormView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let planDisplayTitleAR: String
    let planDisplayTitleEN: String
    let onSaved: ((AdDraft) -> Void)?

    @State private var draft = AdDraft()

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var imageDatas: [Data] = []

    @State private var showValidationAlert = false
    @State private var showSavedToast = false

    private let maxChars: Int = 150
    private let maxImages: Int = 4

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
    private var planTitle: String { lang.isArabic ? planDisplayTitleAR : planDisplayTitleEN }
    private var remainingChars: Int { max(0, maxChars - draft.adText.count) }

    private var isValid: Bool {
        !draft.businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !draft.headline.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !draft.adText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                headerCard
                audienceSection
                photosSection
                textSection
                contactSection
                primaryActions
                    .padding(.top, 6)

                Spacer(minLength: 16)
            }
            .padding()
        }
        .navigationTitle(L("إنشاء إعلان", "Create Ad"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: { Image(systemName: "xmark").imageScale(.medium) }
            }
        }
        .alert(L("تحقق من البيانات", "Check your info"), isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(L("يرجى تعبئة: اسم النشاط + عنوان الإعلان + نص الإعلان.",
                   "Please fill: business name + headline + ad text."))
        }
        .overlay(alignment: .top) {
            if showSavedToast {
                toastView
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 10)
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            Task { await loadImages(from: newItems) }
        }
        .onChange(of: draft.adText) { _, newValue in
            if newValue.count > maxChars {
                draft.adText = String(newValue.prefix(maxChars))
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "megaphone.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.blue.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(L("باقة: ", "Plan: ") + planTitle)
                        .font(.headline)
                    Text(L("املأ الإعلان الآن — الدفع سيكون آخر خطوة.",
                           "Fill your ad now — payment will be the final step."))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(cardBG)
    }

    private var audienceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("الجمهور المستهدف", "Target audience"))
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(AdAudience.allCases, id: \.self) { a in
                        Button {
                            draft.selectedAudience = a
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: iconForAudience(a))
                                Text(labelForAudience(a))
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(draft.selectedAudience == a ? Color.blue.opacity(0.16) : Color(.systemGray6))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .background(cardBG)
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(L("صور المحل", "Business photos"))
                    .font(.headline)
                Spacer()
                Text("\(imageDatas.count)/\(maxImages)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }

            PhotosPicker(selection: $selectedItems, maxSelectionCount: maxImages, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text(L("اختر صور", "Choose photos"))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if imageDatas.isEmpty {
                Text(L("اختياري: أضف 1–4 صور لزيادة فعالية الإعلان.",
                       "Optional: Add 1–4 photos to improve your ad."))
                .font(.footnote)
                .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(imageDatas.enumerated()), id: \.offset) { idx, data in
                            if let ui = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: ui)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 90)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                                    Button { removeImage(at: idx) } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.25))
                                            .clipShape(Circle())
                                    }
                                    .padding(6)
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding()
        .background(cardBG)
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("محتوى الإعلان", "Ad content"))
                .font(.headline)

            TextField(L("اسم النشاط", "Business name"), text: $draft.businessName)
                .textFieldStyle(.roundedBorder)

            TextField(L("عنوان الإعلان (قصير)", "Headline (short)"), text: $draft.headline)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(L("نص الإعلان", "Ad text"))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(L("متبقي: ", "Remaining: ") + "\(remainingChars)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(remainingChars == 0 ? .orange : .secondary)
                }

                TextField(
                    L("اكتب نص الإعلان (حد أقصى 150 حرف)", "Write your ad text (max 150 chars)"),
                    text: $draft.adText,
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
                .lineLimit(4, reservesSpace: true)

                Text(L("مثال: خصم 10% على الساندويتشات اليوم. توصيل متاح.",
                       "Example: 10% off sandwiches today. Delivery available."))
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(cardBG)
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("بيانات التواصل (اختياري)", "Contact info (optional)"))
                .font(.headline)

            TextField(L("الهاتف", "Phone"), text: $draft.phone)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)

            TextField(L("الموقع الإلكتروني", "Website"), text: $draft.website)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.URL)

            TextField(L("عنوان مختصر", "Short address hint"), text: $draft.addressHint)
                .textFieldStyle(.roundedBorder)

            Text(L("لن نستخدم واتساب هنا. واتساب فقط لتوثيق إضافة المكان.",
                   "WhatsApp is not used here. WhatsApp is only for verifying Add Location."))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBG)
    }

    private var primaryActions: some View {
        VStack(spacing: 10) {
            Button {
                guard isValid else {
                    showValidationAlert = true
                    return
                }

                // ✅ Convert selected images -> Base64 & save into draft
                draft.imageBase64s = []   // مؤقتاً: بدون صور

                onSaved?(draft)

                withAnimation(.spring()) { showSavedToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(.easeOut) { showSavedToast = false }
                    dismiss()
                }
            } label: {
                HStack {
                    Spacer()
                    Text(L("حفظ", "Save"))
                        .font(.headline)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color.blue.opacity(0.95))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Text(L("الدفع سيكون آخر خطوة لاحقاً (StoreKit).",
                   "Payment will be the final step later (StoreKit)."))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private var toastView: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            Text(L("تم حفظ الإعلان ✅", "Ad saved ✅"))
                .font(.footnote.weight(.semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.horizontal)
    }

    private func labelForAudience(_ a: AdAudience) -> String {
        switch a {
        case .restaurants: return L("مطاعم", "Restaurants")
        case .mosques:     return L("مساجد", "Mosques")
        case .shops:       return L("محلات", "Shops")
        case .schools:     return L("مدارس", "Schools")
        }
    }

    private func iconForAudience(_ a: AdAudience) -> String {
        switch a {
        case .restaurants: return "fork.knife"
        case .mosques:     return "sparkles"
        case .shops:       return "cart.fill"
        case .schools:     return "book.fill"
        }
    }

    private func removeImage(at index: Int) {
        guard index >= 0 && index < imageDatas.count else { return }
        imageDatas.remove(at: index)
        if index < selectedItems.count { selectedItems.remove(at: index) }
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        var newDatas: [Data] = []
        for item in items.prefix(maxImages) {
            if let data = try? await item.loadTransferable(type: Data.self) {
                newDatas.append(data)
            }
        }
        await MainActor.run { self.imageDatas = newDatas }
    }
}

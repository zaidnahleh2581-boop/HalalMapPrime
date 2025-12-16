//
//  FreeAdFormView.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/15/25.
//

import SwiftUI
import PhotosUI
import UIKit
struct FreeAdFormView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var placeId: String = ""
    @State private var tier: Ad.Tier = .free

    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var pickedImages: [UIImage] = []

    @State private var showSavedAlert = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Form {

                Section(header: Text(lang.isArabic ? "ربط الإعلان بمحل" : "Link ad to a place")) {
                    TextField(lang.isArabic ? "Place ID (من Place.id)" : "Place ID (from Place.id)", text: $placeId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Text(lang.isArabic
                         ? "ملاحظة: الإعلان لازم يكون مربوط بـ Place.id عشان يفتح تفاصيل المحل عند الضغط."
                         : "Note: Ad must match Place.id so tapping opens Place details.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }

                Section(header: Text(lang.isArabic ? "نوع الإعلان" : "Ad tier")) {
                    Picker(lang.isArabic ? "الباقة" : "Plan", selection: $tier) {
                        Text(lang.isArabic ? "مجاني" : "Free").tag(Ad.Tier.free)
                        Text(lang.isArabic ? "مدفوع" : "Standard").tag(Ad.Tier.standard)
                        Text(lang.isArabic ? "Prime" : "Prime").tag(Ad.Tier.prime)
                    }
                }

                Section(header: Text(lang.isArabic ? "صور الإعلان (1–3)" : "Ad images (1–3)")) {

                    PhotosPicker(
                        selection: $pickedItems,
                        maxSelectionCount: 3,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text(lang.isArabic ? "اختر صور" : "Pick photos")
                            Spacer()
                        }
                    }
                    .onChange(of: pickedItems) { newItems in
                        Task { await loadImages(from: newItems) }
                    }

                    if pickedImages.isEmpty {
                        Text(lang.isArabic ? "لم يتم اختيار صور بعد." : "No images selected yet.")
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
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(lang.isArabic ? "إعلان جديد" : "New Ad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.isArabic ? "إغلاق" : "Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.isArabic ? "حفظ" : "Save") {
                        saveAd()
                    }
                }
            }
            .alert(lang.isArabic ? "تم" : "Saved", isPresented: $showSavedAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(lang.isArabic ? "تم حفظ الإعلان بنجاح." : "Ad saved successfully.")
            }
        }
    }

    // MARK: - Load images
    private func loadImages(from items: [PhotosPickerItem]) async {
        pickedImages.removeAll()
        errorMessage = nil

        for item in items.prefix(3) {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                pickedImages.append(img)
            }
        }
    }

    // MARK: - Save
    private func saveAd() {
        errorMessage = nil

        let trimmed = placeId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = lang.isArabic ? "Place ID مطلوب." : "Place ID is required."
            return
        }

        guard (1...3).contains(pickedImages.count) else {
            errorMessage = lang.isArabic ? "اختَر 1 إلى 3 صور." : "Pick 1 to 3 images."
            return
        }

        // خزّن الصور محليًا (لاحقًا Firebase Storage)
        let paths = pickedImages.compactMap { saveImageToDocuments($0) }

        let ad = Ad(
            placeId: trimmed,
            imagePaths: paths,
            tier: tier,
            status: .active
        )

        AdsStore.shared.add(ad)
        showSavedAlert = true
    }

    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.82) else { return nil }
        let filename = "ad_\(UUID().uuidString).jpg"

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        do {
            try data.write(to: url, options: .atomic)
            return filename // نخزن اسم الملف فقط
        } catch {
            print("❌ save image error: \(error)")
            return nil
        }
    }
}

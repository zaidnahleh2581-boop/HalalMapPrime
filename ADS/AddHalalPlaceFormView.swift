//
//  AddHalalPlaceFormView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct AddHalalPlaceFormView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @StateObject private var store = PlaceSubmissionsStore.shared

    // MARK: - Preset
    enum Preset: Equatable {
        case halalPlace
        case foodTruck
        case normal
    }

    private let preset: Preset

    init(preset: Preset = .normal) {
        self.preset = preset
    }

    enum PlaceType: String, CaseIterable, Identifiable {
        case restaurant, grocery, mosque, school, shop, service, foodTruck
        var id: String { rawValue }
    }

    // MARK: - Basic Info
    @State private var placeName: String = ""
    @State private var phone: String = ""
    @State private var placeType: PlaceType = .restaurant

    // MARK: - Location
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var addressLine: String = ""
    @State private var foodTruckStop: String = ""

    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    @State private var didApplyPreset = false

    var body: some View {
        Form {

            Section(header: Text(L("معلومات المكان", "Place info"))) {
                TextField(L("اسم المحل / الفود ترك", "Place name"), text: $placeName)

                TextField(L("رقم الهاتف (اختياري)", "Phone (optional)"), text: $phone)
                    .keyboardType(.phonePad)

                Picker(L("نوع المكان", "Place type"), selection: $placeType) {
                    ForEach(PlaceType.allCases) { t in
                        Text(typeLabel(t)).tag(t)
                    }
                }
            }

            Section(header: Text(L("الموقع", "Location"))) {
                TextField(L("المدينة", "City"), text: $city)
                TextField(L("الولاية", "State"), text: $state)

                if placeType == .foodTruck {
                    TextField(
                        L("أين يقف الفود ترك؟", "Where does the food truck stop?"),
                        text: $foodTruckStop,
                        axis: .vertical
                    )
                    .lineLimit(2...4)
                } else {
                    TextField(L("العنوان", "Address"), text: $addressLine)
                }
            }

            Section {
                Button {
                    Task { await submit() }
                } label: {
                    HStack {
                        Spacer()
                        if store.isSubmitting {
                            ProgressView()
                        } else {
                            Text(L("إضافة المكان على الخريطة", "Add place to the map"))
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
                .disabled(store.isSubmitting)
            }

            Section(footer:
                Text(L(
                    "هذه الخطوة تضيف محلك الحلال كـ Listing على الخريطة. سيتم حفظ الطلب كـ Pending وقد يخضع للمراجعة قبل الظهور.",
                    "This adds your halal place as a listing on the map. The submission is saved as Pending and may be reviewed before appearing."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
            ) { EmptyView() }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
        .onAppear { applyPresetOnceIfNeeded() }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Submit

    private func submit() async {
        // Validation
        let trimmedName = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedState = state.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty || trimmedCity.isEmpty || trimmedState.isEmpty {
            alertTitle = L("نقص في البيانات", "Missing info")
            alertMessage = L("رجاءً عبّي اسم المكان والمدينة والولاية.", "Please fill place name, city, and state.")
            showAlert = true
            return
        }

        if placeType == .foodTruck {
            let stop = foodTruckStop.trimmingCharacters(in: .whitespacesAndNewlines)
            if stop.isEmpty {
                alertTitle = L("نقص في البيانات", "Missing info")
                alertMessage = L("رجاءً اكتب أين يقف الفود ترك.", "Please enter where the food truck stops.")
                showAlert = true
                return
            }
        } else {
            let addr = addressLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if addr.isEmpty {
                alertTitle = L("نقص في البيانات", "Missing info")
                alertMessage = L("رجاءً اكتب العنوان للمحل.", "Please enter the address.")
                showAlert = true
                return
            }
        }

        do {
            let docId = try await store.submitPlace(
                placeName: trimmedName,
                phone: phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : phone,
                placeType: placeType.rawValue,
                city: trimmedCity,
                state: trimmedState,
                addressLine: placeType == .foodTruck ? nil : addressLine,
                foodTruckStop: placeType == .foodTruck ? foodTruckStop : nil
            )

            alertTitle = L("تم الإرسال", "Submitted")
            alertMessage = L(
                "تم إرسال طلبك بنجاح (Pending). رقم الطلب: \(docId)",
                "Your submission was sent successfully (Pending). ID: \(docId)"
            )
            showAlert = true

        } catch {
            alertTitle = L("خطأ", "Error")
            alertMessage = L(
                "صار خطأ أثناء الإرسال: \(error.localizedDescription)",
                "Submission failed: \(error.localizedDescription)"
            )
            showAlert = true
        }
    }

    // MARK: - Preset Logic

    private func applyPresetOnceIfNeeded() {
        guard !didApplyPreset else { return }
        didApplyPreset = true

        switch preset {
        case .foodTruck:
            placeType = .foodTruck
        case .halalPlace:
            if placeType == .foodTruck { placeType = .restaurant }
        case .normal:
            break
        }
    }

    private var navTitle: String {
        switch preset {
        case .foodTruck:
            return L("أضف فود ترك", "Add Food Truck")
        case .halalPlace:
            return L("أضف محلك الحلال", "Add Halal Place")
        case .normal:
            return L("أضف مكان", "Add Place")
        }
    }

    // MARK: - Helpers

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private func typeLabel(_ t: PlaceType) -> String {
        switch t {
        case .restaurant: return L("مطعم", "Restaurant")
        case .grocery: return L("بقالة / سوبرماركت", "Grocery / Market")
        case .mosque: return L("مسجد", "Mosque")
        case .school: return L("مدرسة / تعليم", "School / Education")
        case .shop: return L("متجر", "Shop")
        case .service: return L("خدمة", "Service")
        case .foodTruck: return L("فود ترك", "Food Truck")
        }
    }
}

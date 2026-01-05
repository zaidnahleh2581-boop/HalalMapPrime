//
//  AddHalalPlaceFormView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
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

    // ✅ Gate mode: community monthly vs ads lifetime gift
    private let gateMode: PlaceSubmissionsStore.GateMode
    private let preset: Preset

    // ✅ Control Close button (fix duplicate Close)
    private let showsCloseButton: Bool

    // ✅ Callbacks (NO manual edits elsewhere)
    private let onGiftConsumedOrAttempted: (() -> Void)?
    private let onNeedPaidUpgrade: (() -> Void)?

    init(
        preset: Preset = .normal,
        gateMode: PlaceSubmissionsStore.GateMode = .communityMonthly(phone: nil),
        showsCloseButton: Bool = true,
        onGiftConsumedOrAttempted: (() -> Void)? = nil,
        onNeedPaidUpgrade: (() -> Void)? = nil
    ) {
        self.preset = preset
        self.gateMode = gateMode
        self.showsCloseButton = showsCloseButton
        self.onGiftConsumedOrAttempted = onGiftConsumedOrAttempted
        self.onNeedPaidUpgrade = onNeedPaidUpgrade
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

    // Alerts
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    // ✅ Special “gift used” alert with actions
    @State private var showGiftUsedAlert = false

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
                            Text(submitButtonTitle)
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
                .disabled(store.isSubmitting)
            }

            Section(footer: Text(footerText)
                .font(.footnote)
                .foregroundColor(.secondary)
            ) { EmptyView() }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // ✅ Close button shown only when requested (prevents duplicate Close)
            if showsCloseButton {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("إغلاق", "Close")) { dismiss() }
                }
            }
        }
        .onAppear { applyPresetOnceIfNeeded() }

        // Normal alert
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }

        // ✅ Gift-used alert with action to Paid
        .alert(L("تم استخدام الإضافة المجانية", "Free add already used"), isPresented: $showGiftUsedAlert) {
            Button(L("إلغاء", "Cancel"), role: .cancel) { }
            Button(L("انتقل للإعلانات المدفوعة", "Go to Paid Ads")) {
                dismiss()
                onGiftConsumedOrAttempted?()
                onNeedPaidUpgrade?()
            }
        } message: {
            Text(L(
                "تم استخدام الإضافة المجانية لهذا المحل/اللوكيشن سابقًا. يمكنك المتابعة بإعلان مدفوع لزيادة الظهور.",
                "This business/location already used the free add. You can continue with a paid ad to boost visibility."
            ))
        }
    }

    // MARK: - Submit

    private func submit() async {
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
            _ = try await store.submitPlace(
                placeName: trimmedName,
                phone: phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : phone,
                placeType: placeType.rawValue,
                city: trimmedCity,
                state: trimmedState,
                addressLine: placeType == .foodTruck ? nil : addressLine,
                foodTruckStop: placeType == .foodTruck ? foodTruckStop : nil,
                gateMode: gateMode
            )

            // ✅ Mark gift as used locally immediately (hide button), then close
            if case .adsLifetimeGift = gateMode {
                onGiftConsumedOrAttempted?()
            }

            alertTitle = L("تم الإرسال", "Submitted")
            alertMessage = L(
                "تم إرسال طلبك بنجاح (قيد المراجعة).",
                "Your submission was sent successfully (Pending review)."
            )
            showAlert = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                dismiss()
            }

        } catch let e as PlaceSubmissionsStore.SubmitError {
            switch e {
            case .lifetimeGiftAlreadyUsed:
                showGiftUsedAlert = true
            }
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
            return L("أضف فود ترك حلال", "Add Halal Food Truck")
        case .halalPlace:
            return L("أضف مكان حلال", "Add Halal Place")
        case .normal:
            // ✅ If this is the free gift flow, make title map-focused
            if case .adsLifetimeGift = gateMode {
                return L("أضف موقعك على الخريطة", "Add your place to the map")
            }
            return L("أضف مكان", "Add Place")
        }
    }

    private var submitButtonTitle: String {
        switch gateMode {
        case .adsLifetimeGift:
            return L("إضافة إلى الخريطة (مرة واحدة)", "Add to map (one-time)")
        default:
            return L("إضافة المكان على الخريطة", "Add place to the map")
        }
    }

    private var footerText: String {
        switch gateMode {
        case .adsLifetimeGift:
            return L(
                "هذه إضافة مجانية مرة واحدة للعُمر لكل محل/لوكيشن. إذا تم استخدامها سابقًا لنفس العنوان/الموقع سيتم منعها تلقائيًا.",
                "This is a lifetime one-time free add per business/location. If already used for the same place, it will be blocked automatically."
            )
        case .communityMonthly:
            return L(
                "هذه إضافة مجتمعية (Monthly). قد تتجدد حسب نظام المجتمع لديك.",
                "This is a Community monthly flow. It may renew based on your community system."
            )
        case .none:
            return L("إضافة عادية.", "Normal submission.")
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

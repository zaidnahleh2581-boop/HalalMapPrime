//
//  AdsHomeView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import Combine
import FirebaseAuth

// MARK: - Free Gift State Store (in-file, no extra files needed)
@MainActor
final class FreeGiftBannerStore: ObservableObject {

    enum State: Equatable {
        case loading
        case neverUsed
        case alreadyUsed
        case error(String)
    }

    @Published var state: State = .loading

    func refresh(phone: String?) {
        state = .loading
        Task {
            do {
                _ = try await ensureUID()
                let canUse = try await MonthlyFreeGate.shared.canUseFreeThisMonth(phone: phone)
                self.state = canUse ? .neverUsed : .alreadyUsed
            } catch {
                self.state = .error(error.localizedDescription)
            }
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

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // ✅ Needed (was missing in your errors)
    @State private var showComingSoon = false

    // Sheets
    @State private var showAddPlaceSheet = false
    @State private var showMyAdsSheet = false
    @State private var showPrivacySheet = false

    // ✅ Free gift banner store (self-contained)
    @StateObject private var freeGiftStore = FreeGiftBannerStore()

    // MARK: - Tabs
    enum TopTab: String, CaseIterable, Identifiable {
        case free
        case myAds
        case privacy
        var id: String { rawValue }
    }

    @State private var selectedTab: TopTab = .free

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            topTabs
            Divider().opacity(0.20)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // ✅ FREE GIFT Banner (One-time)
                    freeGiftBanner

                    Text(L("إعلانات مدفوعة", "Paid Ads"))
                        .font(.title2.weight(.bold))
                        .padding(.top, 2)

                    paidCard(
                        title: L("إعلان مدفوع (باقات)", "Paid Ads (Packages)"),
                        subtitle: L("يومي / أسبوعي / شهري — ظهور أعلى على الخريطة والزيارات.", "Daily / Weekly / Monthly — higher visibility on map & visits."),
                        icon: "creditcard.fill",
                        tint: .cyan
                    ) {
                        showComingSoon = true
                    }

                    paidCard(
                        title: L("Prime Ads (أفضل ظهور)", "Prime Ads (Top Visibility)"),
                        subtitle: L("بانر مميز + أولوية أعلى داخل التطبيق.", "Featured banner + higher priority inside the app."),
                        icon: "sparkles",
                        tint: .orange
                    ) {
                        showComingSoon = true
                    }

                    Spacer(minLength: 18)
                }
                .padding()
            }
        }
        .navigationTitle(L("الإعلانات", "Ads"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
            }
        }
        .alert(L("قريباً", "Coming Soon"), isPresented: $showComingSoon) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(L("هذه الميزة قيد التجهيز. سنفعّلها قريباً.", "This feature is being prepared and will be enabled soon."))
        }

        // ✅ Add Place Sheet
        .sheet(isPresented: $showAddPlaceSheet) {
            NavigationStack {
                AddHalalPlaceFormView(preset: .normal)
                    .environmentObject(lang)
                    .navigationTitle(L("إضافة مكان", "Add Place"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) { showAddPlaceSheet = false }
                        }
                    }
            }
        }

        // ✅ My Ads Sheet
        .sheet(isPresented: $showMyAdsSheet) {
            NavigationStack {
                MyAdsView()
                    .environmentObject(lang)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) { showMyAdsSheet = false }
                        }
                    }
            }
        }

        // ✅ Privacy Sheet
        .sheet(isPresented: $showPrivacySheet) {
            NavigationStack {
                AdsPrivacyView()
                    .environmentObject(lang)
                    .navigationTitle(L("الخصوصية والأمان", "Privacy & Safety"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) { showPrivacySheet = false }
                        }
                    }
            }
        }

        // ✅ Refresh free gift status when view appears
        .onAppear {
            // phone is optional gate; if you later store phone globally, pass it here
            freeGiftStore.refresh(phone: nil)
        }
    }

    // MARK: - Top Tabs

    private var topTabs: some View {
        HStack(spacing: 10) {

            tabButton(
                title: L("إضافة مكان (مجاني)", "Add Place (Free)"),
                systemImage: "mappin.and.ellipse",
                tint: .blue,
                isSelected: selectedTab == .free
            ) {
                selectedTab = .free
                showAddPlaceSheet = true
            }

            tabButton(
                title: L("إعلاناتي", "My Ads"),
                systemImage: "doc.text.magnifyingglass",
                tint: .purple,
                isSelected: selectedTab == .myAds
            ) {
                selectedTab = .myAds
                showMyAdsSheet = true
            }

            tabButton(
                title: L("الخصوصية\nوالأمان", "Privacy\n& Safety"),
                systemImage: "lock.fill",
                tint: .gray,
                isSelected: selectedTab == .privacy
            ) {
                selectedTab = .privacy
                showPrivacySheet = true
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Free Gift Banner (One-time)

    @ViewBuilder
    private var freeGiftBanner: some View {
        switch freeGiftStore.state {

        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                Text(L("جاري التحقق من الهدية...", "Checking free gift..."))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(cardBG)

        case .neverUsed:
            VStack(alignment: .leading, spacing: 10) {

                HStack(spacing: 10) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.green.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("🎁 إعلان مجاني — هدية من التطبيق", "🎁 Free Ad — Gift from the app"))
                            .font(.headline)

                        Text(L("لمرة واحدة فقط • مدة 30 يوم", "One-time only • 30 days"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }

                Text(L(
                    "جرّب البرنامج براحتك. قبل ما ينتهي الإعلان بنذكّرك في آخر أسبوع + قبل 24 ساعة.",
                    "Try the app comfortably. We’ll remind you in the last week + 24 hours before expiry."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)

                Button {
                    showAddPlaceSheet = true
                } label: {
                    HStack {
                        Spacer()
                        Text(L("ابدأ الإعلان المجاني", "Start Free Ad"))
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.green.opacity(0.95))
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(cardBG)

        case .alreadyUsed:
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)

                    Text(L("تم استخدام الهدية المجانية", "Free gift already used"))
                        .font(.headline)

                    Spacer()
                }

                Text(L(
                    "الهدية كانت لمرة واحدة فقط. تابع الآن على الباقات المدفوعة.",
                    "The free gift was one-time only. Continue with paid plans."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(cardBG)

        case .error(let message):
            VStack(alignment: .leading, spacing: 6) {
                Text(L("ملاحظة", "Note"))
                    .font(.headline)
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(cardBG)
        }
    }

    // MARK: - UI Helpers

    private func paidCard(title: String, subtitle: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.18))
                    .foregroundColor(tint)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.headline)
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(cardBG)
        }
        .buttonStyle(.plain)
    }

    private func tabButton(title: String, systemImage: String, tint: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? tint.opacity(0.92) : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? .white : (tint == .gray ? .primary : tint))
        }
        .buttonStyle(.plain)
    }

    // ✅ This fixes your “Cannot find cardBG”
    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}

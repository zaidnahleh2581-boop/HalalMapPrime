//
//  AdsHomeScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct AdsHomeScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @State private var showComingSoon = false

    // ✅ Free gift state (Option C)
    @StateObject private var freeStore = FreeAdStateStore()

    // Sheets
    @State private var showAddPlaceSheet = false
    @State private var showMyAdsSheet = false
    @State private var showPrivacySheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    // ✅ Free Gift Banner (Option C)
                    freeGiftBanner

                    // Header
                    Text(L("الإعلانات المدفوعة", "Paid Ads"))
                        .font(.largeTitle.bold())
                        .padding(.top, 6)

                    Text(L(
                        "هذا القسم مخصص للإعلانات المدفوعة لزيادة ظهور نشاطك على الخريطة والبنرات داخل التطبيق.",
                        "This section is for paid promotions to boost your visibility on the map and banners inside the app."
                    ))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    premiumBanner

                    // Actions
                    VStack(spacing: 12) {

                        actionButton(
                            titleAR: "ابدأ إعلان مدفوع (أسبوعي / شهري)",
                            titleEN: "Start a Paid Ad (Weekly / Monthly)",
                            systemImage: "creditcard.fill",
                            tint: .orange
                        ) { showComingSoon = true }

                        actionButton(
                            titleAR: "Prime Ads (أفضل ظهور)",
                            titleEN: "Prime Ads (Best visibility)",
                            systemImage: "sparkles",
                            tint: .orange
                        ) { showComingSoon = true }

                        actionButton(
                            titleAR: "إعلاناتي",
                            titleEN: "My Ads",
                            systemImage: "doc.text.magnifyingglass",
                            tint: .purple
                        ) { showMyAdsSheet = true }

                        actionButton(
                            titleAR: "إضافة مكان",
                            titleEN: "Add Place",
                            systemImage: "mappin.and.ellipse",
                            tint: .blue
                        ) { showAddPlaceSheet = true }

                        actionButton(
                            titleAR: "الخصوصية والأمان",
                            titleEN: "Privacy & Safety",
                            systemImage: "lock.fill",
                            tint: .gray
                        ) { showPrivacySheet = true }
                    }

                    Text(L(
                        "ملاحظة: سيتم ربط الدفع (In-App Purchases) لاحقاً بطريقة رسمية ومتوافقة مع Apple.",
                        "Note: Payments (In-App Purchases) will be connected later in an official Apple-compliant way."
                    ))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)

                    Spacer(minLength: 24)
                }
                .padding()
            }
            .navigationTitle(L("الإعلانات", "Ads"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { freeStore.refresh() }

            .alert(L("قريباً", "Coming Soon"), isPresented: $showComingSoon) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(L("هذه الميزة قيد التجهيز. سنفعّلها قريباً.", "This feature is being prepared and will be enabled soon."))
            }

            // ✅ Add Place Sheet (onDismiss refresh free state)
            .sheet(isPresented: $showAddPlaceSheet, onDismiss: { freeStore.refresh() }) {
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
        }
    }

    // MARK: - Free Gift Banner (Option C) ✅ FIXED with ViewBuilder

    @ViewBuilder
    private var freeGiftBanner: some View {
        switch freeStore.state {

        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                Text(L("جاري التحقق من الهدية...", "Checking gift status..."))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(cardBG)

        case .neverUsed:
            VStack(alignment: .leading, spacing: 8) {
                Text(L("🎁 إعلان مجاني — هدية من التطبيق", "🎁 Free Ad — Gift from the app"))
                    .font(.headline)

                Text(L("مرة واحدة فقط — مدة 30 يوم.", "One-time only — 30 days."))
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
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.92)))
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(cardBG)

        case .alreadyUsed:
            VStack(alignment: .leading, spacing: 8) {
                Text(L("✅ تم استخدام الإعلان المجاني", "✅ Free ad already used"))
                    .font(.headline)

                Text(L(
                    "الهدية كانت لمرة واحدة. إذا حابب تكمل ظهورك، انتقل للباقات المدفوعة.",
                    "The free gift was one-time. To keep visibility, move to paid plans."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)

                Button {
                    showComingSoon = true
                } label: {
                    HStack {
                        Spacer()
                        Text(L("عرض الباقات المدفوعة", "View Paid Plans"))
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.55)))
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(cardBG)

        case .error(let msg):
            VStack(alignment: .leading, spacing: 6) {
                Text(L("ملاحظة", "Note")).font(.headline)
                Text(L("تعذر التحقق: ", "Could not check: ") + msg)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(cardBG)
        }
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    // MARK: - Premium Banner

    private var premiumBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.98), Color.orange.opacity(0.78)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.18))
                    Image(systemName: "megaphone.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L("روّج لعملك الحلال", "Promote your halal business"))
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(L("ظهور أعلى على الخريطة + بنرات داخل التطبيق.", "Higher visibility on the map + banners inside the app."))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)

                    Text(L("Prime • كوبونات • عروض", "Prime • Coupons • Offers"))
                        .font(.caption2.bold())
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.20))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.top, 2)
                }

                Spacer()
            }
            .padding(14)
        }
        .frame(height: 110)
        .shadow(color: Color.orange.opacity(0.25), radius: 8, x: 0, y: 4)
    }

    // MARK: - Action Button

    private func actionButton(
        titleAR: String,
        titleEN: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                Text(lang.isArabic ? titleAR : titleEN)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.92))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}

//
//  AdsHomeView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var showAddPlaceForm: Bool = false
    @State private var showPaidAdPlans: Bool = false
    @State private var showPrimeAdPlans: Bool = false
    @State private var showMyAds: Bool = false

    // ✅ Preset chooser for the form
    @State private var currentPreset: AddHalalPlaceFormView.Preset = .normal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    headerSection
                    introSection

                    // ✅ Quick Actions (ظاهرين من الخارج)
                    quickActions

                    VStack(spacing: 12) {
                        paidAdCard
                        primeAdCard
                        myAdsCard
                    }
                    .padding(.top, 6)

                    footerNote
                        .padding(.top, 10)

                    Spacer(minLength: 24)
                }
                .padding()
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
            // MARK: Sheets
            .sheet(isPresented: $showAddPlaceForm) {
                NavigationStack {
                    AddHalalPlaceFormView(preset: currentPreset)
                        .environmentObject(lang)
                }
            }
            .sheet(isPresented: $showPaidAdPlans) {
                NavigationStack {
                    SelectAdPlanView()
                        .environmentObject(lang)
                }
            }
            .sheet(isPresented: $showPrimeAdPlans) {
                NavigationStack {
                    SelectAdPlanView()
                        .environmentObject(lang)
                }
            }
            .sheet(isPresented: $showMyAds) {
                NavigationStack {
                    MyAdsView()
                        .environmentObject(lang)
                }
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("الإعلانات في Halal Map Prime", "Ads in Halal Map Prime"))
                .font(.title2.weight(.semibold))

            Text(
                L(
                    "ابدأ بإضافة محلك الحلال على الخريطة مجاناً (Listing). الترويج الحقيقي والظهور الأعلى يكون عبر الإعلانات المدفوعة.",
                    "Start by adding your halal place to the map for free (Listing). Real promotion and top visibility come via paid ads."
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var introSection: some View {
        Text(
            L(
                "ملاحظة: الإضافة المجانية لا تسمح بنص حر. هذا يقلل السبام ويساعد على قبول Apple.",
                "Note: the free listing does not allow free text. This reduces spam and helps Apple compliance."
            )
        )
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L("إجراءات سريعة", "Quick actions"))
                .font(.headline)

            HStack(spacing: 10) {
                actionButton(
                    title: L("أضف محلك الحلال", "Add Halal Place"),
                    systemImage: "plus.circle.fill",
                    tint: .green
                ) {
                    currentPreset = .halalPlace
                    showAddPlaceForm = true
                }

                actionButton(
                    title: L("أضف فود ترك", "Add Food Truck"),
                    systemImage: "truck.box.fill",
                    tint: .orange
                ) {
                    currentPreset = .foodTruck
                    showAddPlaceForm = true
                }
            }

            actionButtonFullWidth(
                title: L("إضافة مكان (مجاني)", "Add place (Free)"),
                systemImage: "mappin.and.ellipse",
                tint: .blue
            ) {
                currentPreset = .normal
                showAddPlaceForm = true
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }

    // MARK: - Cards

    private var paidAdCard: some View {
        homeCard(
            titleAr: "إعلان مدفوع (باقات)",
            titleEn: "Paid ads (Plans)",
            subtitleAr: "يومي / أسبوعي / شهري — ظهور أعلى على الخريطة والبنرات.",
            subtitleEn: "Daily / Weekly / Monthly — higher visibility on map and banners.",
            icon: "creditcard.fill",
            tint: .blue
        ) { showPaidAdPlans = true }
    }

    private var primeAdCard: some View {
        homeCard(
            titleAr: "Prime Ads (أفضل ظهور)",
            titleEn: "Prime Ads (Best visibility)",
            subtitleAr: "بانر مميز + أولوية أعلى داخل التطبيق.",
            subtitleEn: "Featured banner + higher priority across the app.",
            icon: "sparkles",
            tint: .orange
        ) { showPrimeAdPlans = true }
    }

    private var myAdsCard: some View {
        homeCard(
            titleAr: "أماكني / إعلاناتي",
            titleEn: "My Places / My Ads",
            subtitleAr: "تابع حالة إضافاتك وإعلاناتك: Pending / Active / Expired.",
            subtitleEn: "Track your submissions and ads: Pending / Active / Expired.",
            icon: "doc.text.magnifyingglass",
            tint: .purple
        ) { showMyAds = true }
    }

    private var footerNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("ملاحظة سياسة", "Policy note"))
                .font(.footnote.weight(.semibold))

            Text(
                L(
                    "المحتوى يجب أن يكون قانوني ومتوافق مع سياسات Apple ومعايير Halal Map Prime. قد يتم تعليق أي إدراج أو إعلان مخالف.",
                    "Content must be legal and comply with Apple policies and Halal Map Prime standards. Violations may be removed."
                )
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
    }

    // MARK: - Components

    private func homeCard(
        titleAr: String,
        titleEn: String,
        subtitleAr: String,
        subtitleEn: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button { action() } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.18))
                    Image(systemName: icon)
                        .foregroundColor(tint)
                        .font(.headline)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L(titleAr, titleEn))
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(L(subtitleAr, subtitleEn))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
    }

    private func actionButton(title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.footnote.weight(.semibold))
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.15))
            .foregroundColor(tint)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func actionButtonFullWidth(title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(tint.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}

struct AdsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        AdsHomeView()
            .environmentObject(LanguageManager())
    }
}

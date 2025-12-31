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

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Tabs
    enum TopTab: String, CaseIterable, Identifiable {
        case free
        case myAds
        case privacy
        var id: String { rawValue }
    }

    @State private var selectedTab: TopTab = .free

    // Sheets
    @State private var showAddPlaceSheet = false
    @State private var showMyAdsSheet = false
    @State private var showPrivacySheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            topTabs

            Divider().opacity(0.20)

            // ✅ Main page stays PAID content always (clean)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text(L("إعلانات مدفوعة", "Paid Ads"))
                        .font(.title2.weight(.bold))
                        .padding(.top, 2)

                    paidCard(
                        title: L("إعلان مدفوع (باقات)", "Paid Ads (Packages)"),
                        subtitle: L("يومي / أسبوعي / شهري — ظهور أعلى على الخريطة والزيارات.", "Daily / Weekly / Monthly — higher visibility on map & visits."),
                        icon: "creditcard.fill",
                        tint: .cyan
                    ) {
                        // TODO: open packages
                    }

                    paidCard(
                        title: L("Prime Ads (أفضل ظهور)", "Prime Ads (Top Visibility)"),
                        subtitle: L("بانر مميز + أولوية أعلى داخل التطبيق.", "Featured banner + higher priority inside the app."),
                        icon: "sparkles",
                        tint: .orange
                    ) {
                        // TODO: open prime
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

        // ✅ Add Place Sheet (close returns here)
        .sheet(isPresented: $showAddPlaceSheet) {
            NavigationStack {
                AddHalalPlaceFormView(preset: .normal)
                    .environmentObject(lang)
                    .navigationTitle(L("إضافة مكان", "Add Place"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) {
                                showAddPlaceSheet = false
                            }
                        }
                    }
            }
        }

        // ✅ My Ads Sheet (close returns here)
        .sheet(isPresented: $showMyAdsSheet) {
            NavigationStack {
                MyAdsView()
                    .environmentObject(lang)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) {
                                showMyAdsSheet = false
                            }
                        }
                    }
            }
        }

        // ✅ Privacy Sheet (close returns here)
        .sheet(isPresented: $showPrivacySheet) {
            NavigationStack {
                AdsPrivacyView()
                    .environmentObject(lang)
                    .navigationTitle(L("الخصوصية والأمان", "Privacy & Safety"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(L("إغلاق", "Close")) {
                                showPrivacySheet = false
                            }
                        }
                    }
            }
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

    // MARK: - UI

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
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
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

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}

//
//  AdsHomeView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var adsStore = AdsStore()

    @State private var showAddressSheet = false
    @State private var showFreeAdSheet = false
    @State private var showPaidSheet = false
    @State private var showFreeLimitAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {

                // Top row
                HStack(spacing: 10) {

                    Button { showAddressSheet = true } label: {
                        topPill(
                            title: L("أضف عنوانك", "Add your address"),
                            systemImage: "mappin.and.ellipse",
                            tint: .blue
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        if adsStore.canUseFreeGift {
                            showFreeAdSheet = true
                        } else {
                            showFreeLimitAlert = true
                        }
                    } label: {
                        topPill(
                            title: L("إعلان مجاني", "Free Ad"),
                            systemImage: "gift.fill",
                            tint: .green
                        )
                        .opacity(adsStore.canUseFreeGift ? 1 : 0.35)
                    }
                    .buttonStyle(.plain)

                    Button { showPaidSheet = true } label: {
                        topPill(
                            title: L("مدفوع", "Paid"),
                            systemImage: "creditcard.fill",
                            tint: .orange
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {

                        Text(L("إعلاناتك", "Your Ads"))
                            .font(.title3.bold())
                            .padding(.horizontal, 14)
                            .padding(.top, 6)

                        Text(L(
                            "الإعلان المجاني هدية مرة واحدة فقط (30 يوم ومميز). بعد استخدامها ينتقل المستخدم للمدفوع.",
                            "Free ad is a one-time gift (30 days, featured). After using it, users move to paid plans."
                        ))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)

                        if adsStore.myAds.isEmpty {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                                .frame(height: 180)
                                .overlay(
                                    Text(L("لا يوجد إعلانات بعد", "No ads yet"))
                                        .foregroundStyle(.secondary)
                                )
                                .padding(.horizontal, 14)
                                .padding(.top, 6)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(adsStore.myAds) { ad in
                                    adCard(ad)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.top, 6)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(L("الإعلانات", "Ads"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { adsStore.load() }
        }
        // Paid (UI فقط الآن)
        .sheet(isPresented: $showPaidSheet) {
            NavigationStack {
                SelectAdPlanView()
                    .environmentObject(lang)
                    .environmentObject(adsStore) // ✅ إذا SelectAdPlanView بدها تخزن إعلان
            }
        }
        // Free (treated like featured 30 days)
        .sheet(isPresented: $showFreeAdSheet) {
            NavigationStack {
                CreateAdFormView(
                    planDisplayTitleAR: "إعلان مجاني (30 يوم) — مميز",
                    planDisplayTitleEN: "Free Ad (30 days) — Featured",
                    onSaved: { draft in
                        adsStore.createAdFromDraft(draft: draft, plan: .freeOnce)
                        adsStore.markFreeGiftUsed()
                        showFreeAdSheet = false
                    }
                )
                .environmentObject(lang)
            }
        }
        // Address
        .sheet(isPresented: $showAddressSheet) {
            NavigationStack { HMPAddressSheet().environmentObject(lang) }
        }
        // Alert
        .alert(L("تم استخدام الهدية المجانية", "Free gift already used"),
               isPresented: $showFreeLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(L(
                "لقد استخدمت إعلانك المجاني مرة واحدة. الآن يمكنك اختيار خطة مدفوعة.",
                "You already used your free ad once. Please choose a paid plan."
            ))
        }
    }

    // MARK: - UI

    private func topPill(title: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).font(.subheadline.weight(.semibold))
            Text(title).font(.subheadline.weight(.semibold)).lineLimit(1)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 14).fill(tint.opacity(0.15)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.35), lineWidth: 1))
    }

    private func adCard(_ ad: HMPAd) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(ad.headline).font(.headline)
                Spacer()
                Text(ad.isActive ? L("نشط", "Active") : L("منتهي", "Expired"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ad.isActive ? .green : .orange)
            }

            Text(ad.businessName).font(.subheadline.weight(.semibold))
            Text(ad.adText).font(.footnote).foregroundStyle(.secondary)

            HStack(spacing: 10) {
                if ad.isFeatured {
                    Label(L("مميز", "Featured"), systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                }

                Text(ad.plan.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(shortDate(ad.expiresAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private func shortDate(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        return f.string(from: d)
    }

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }
}

// Address Sheet
private struct HMPAddressSheet: View {
    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var addressText: String = ""

    var body: some View {
        Form {
            Section(header: Text(lang.isArabic ? "عنوانك" : "Your Address")) {
                TextField(lang.isArabic ? "اكتب العنوان" : "Enter address", text: $addressText)
            }
            Section {
                Button(lang.isArabic ? "حفظ" : "Save") { dismiss() }
            }
        }
        .navigationTitle(lang.isArabic ? "أضف عنوانك" : "Add Address")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(lang.isArabic ? "إغلاق" : "Close") { dismiss() }
            }
        }
    }
}

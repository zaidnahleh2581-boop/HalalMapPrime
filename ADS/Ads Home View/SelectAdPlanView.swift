//
//  SelectAdPlanView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct SelectAdPlanView: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var adsStore: AdsStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: HMPAdPlanKind? = nil
    @State private var showCreateForm: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text(L("اختر خطة الإعلان", "Choose an ad plan"))
                    .font(.title2.bold())
                    .padding(.top, 4)

                Text(L(
                    "ملاحظة: حالياً بعد اختيار الخطة سيتم فتح صفحة تعبئة الإعلان مباشرة (بدون الدفع) لتجهيز Apple Review. الدفع نضيفه بعدين.",
                    "Note: For now, selecting a plan opens the ad form directly (no payment) to keep Apple Review clean. We’ll add payment later."
                ))
                .font(.footnote)
                .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    planRow(.weekly)
                    planRow(.monthly)
                    planRow(.prime)
                }
                .padding(.top, 4)

                Spacer(minLength: 10)
            }
            .padding()
        }
        .navigationTitle(L("الخطط", "Plans"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
        .sheet(isPresented: $showCreateForm) {
            if let plan = selectedPlan {
                NavigationStack {
                    CreateAdFormView(
                        planDisplayTitleAR: planDisplayTitleAR(plan),
                        planDisplayTitleEN: planDisplayTitleEN(plan),
                        onSaved: { draft in
                            // ✅ Creates and saves locally (AdsStore)
                            adsStore.createAdFromDraft(draft: draft, plan: plan)
                            adsStore.load()
                            showCreateForm = false
                            dismiss()
                        }
                    )
                    .environmentObject(lang)
                }
            }
        }
    }

    // MARK: - Row

    private func planRow(_ plan: HMPAdPlanKind) -> some View {
        Button {
            selectedPlan = plan
            showCreateForm = true
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(plan.tint.opacity(0.9))
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 3) {
                    Text(lang.isArabic ? plan.titleAR : plan.titleEN)
                        .font(.headline)

                    Text(lang.isArabic ? plan.durationTextAR : plan.durationTextEN)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Text(lang.isArabic ? plan.placementTextAR : plan.placementTextEN)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Titles for Form

    private func planDisplayTitleAR(_ plan: HMPAdPlanKind) -> String {
        switch plan {
        case .weekly:  return "إعلان أسبوعي (7 أيام)"
        case .monthly: return "إعلان شهري (30 يوم)"
        case .prime:   return "إعلان مميز PRIME (30 يوم)"
        case .freeOnce:return "إعلان مجاني (مرة واحدة)"
        }
    }

    private func planDisplayTitleEN(_ plan: HMPAdPlanKind) -> String {
        switch plan {
        case .weekly:  return "Weekly Ad (7 days)"
        case .monthly: return "Monthly Ad (30 days)"
        case .prime:   return "PRIME Ad (30 days)"
        case .freeOnce:return "Free Ad (One time)"
        }
    }

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }
}

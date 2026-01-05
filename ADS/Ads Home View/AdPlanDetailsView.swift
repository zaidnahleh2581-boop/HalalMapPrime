//
//  AdPlanDetailsView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

// ✅ هذا الملف الوحيد الذي يحتوي AdPlanDetailsView (لمنع redeclaration)
struct AdPlanDetailsView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let plan: HMPAdPlanKind
    var onContinue: (() -> Void)? = nil

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private var title: String { lang.isArabic ? plan.titleAR : plan.titleEN }
    private var duration: String { lang.isArabic ? plan.durationTextAR : plan.durationTextEN }
    private var placement: String { lang.isArabic ? plan.placementTextAR : plan.placementTextEN }

    var body: some View {
        VStack(spacing: 14) {

            HStack(spacing: 10) {
                Circle()
                    .fill(plan.tint)
                    .frame(width: 10, height: 10)

                Text(title)
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.top, 10)

            infoCard(
                title: L("المدة", "Duration"),
                value: duration,
                subtitle: L("مكان الظهور", "Where it shows"),
                subtitleValue: placement
            )

            Button {
                if let onContinue { onContinue() }
                else { dismiss() }
            } label: {
                Text(L("متابعة", "Continue"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.accentColor.opacity(0.85)))
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)

            Button {
                dismiss()
            } label: {
                Text(L("رجوع", "Back"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
            }

            Spacer()
        }
        .padding(16)
        .navigationTitle(L("تفاصيل الإعلان", "Ad Details"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoCard(title: String, value: String, subtitle: String, subtitleValue: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            Text(value).foregroundStyle(.secondary)

            Divider().opacity(0.3)

            Text(subtitle).font(.headline)
            Text(subtitleValue).foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

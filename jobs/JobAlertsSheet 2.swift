//
//  JobAlertsSheet.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-29.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct JobAlertsSheet: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 44, weight: .semibold))
                    .padding(.top, 8)

                Text(L("تنبيهات الوظائف", "Job Alerts"))
                    .font(.title2.bold())

                Text(
                    L(
                        "هذا القسم تحت التطوير.\nقريباً ستقدر تفعل تنبيهات حسب المدينة والمسافة ونوع الوظيفة.",
                        "This section is under development.\nSoon you’ll be able to enable alerts by city, distance, and job type."
                    )
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 18)

                Button {
                    dismiss()
                } label: {
                    Text(L("إغلاق", "Close"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 18)

                Spacer()
            }
            .padding()
            .navigationTitle(L("تنبيهات الوظائف", "Job Alerts"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("إغلاق", "Close")) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    JobAlertsSheet()
        .environmentObject(LanguageManager())
}

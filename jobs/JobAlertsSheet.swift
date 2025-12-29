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

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)

                Text(L("تنبيهات الوظائف", "Job Alerts"))
                    .font(.title2.bold())

                Text(
                    L(
                        "هنا سيتم عرض تنبيهات الوظائف القريبة منك حسب المسافة التي تحددها.",
                        "Here you will receive job alerts near you based on your selected distance."
                    )
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text(L("إغلاق", "Close"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(14)
                }
            }
            .padding()
            .navigationTitle(L("تنبيهات", "Alerts"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

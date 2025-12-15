//
//  LanguageSelectionView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-15.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct LanguageSelectionView: View {

    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        VStack(spacing: 18) {

            Spacer()

            Image(systemName: "globe")
                .font(.system(size: 46))
                .foregroundColor(.secondary)

            Text(L("اختر لغة التطبيق", "Choose App Language"))
                .font(.title2.bold())

            Text(L("يمكنك تغيير اللغة لاحقاً من الإعدادات.", "You can change the language later in Settings."))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {

                Button {
                    lang.select(.arabic)
                } label: {
                    HStack {
                        Text("العربية")
                            .font(.headline)
                        Spacer()
                        Image(systemName: lang.current == .arabic ? "checkmark.circle.fill" : "circle")
                            .imageScale(.large)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)

                Button {
                    lang.select(.english)
                } label: {
                    HStack {
                        Text("English")
                            .font(.headline)
                        Spacer()
                        Image(systemName: lang.current == .english ? "checkmark.circle.fill" : "circle")
                            .imageScale(.large)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            Spacer()

            Text(L("بالاستمرار أنت توافق على سياسة الخصوصية وشروط الاستخدام.", "By continuing, you agree to the Privacy Policy and Terms of Use."))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                // يكفي أن didChooseLanguage صار true داخل select()
                // والـ Root view المفروض يبدّل تلقائياً للشاشات الرئيسية
            } label: {
                Text(L("متابعة", "Continue"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.92))
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding(.top, 14)
    }
}

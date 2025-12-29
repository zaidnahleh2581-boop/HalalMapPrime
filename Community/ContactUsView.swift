//
//  ContactUsView.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/29/25.
//

import SwiftUI

struct ContactUsView: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    // غيّره إذا قصدك بريد حقيقي
    private let contactEmail: String = "info.halalmapprime.com"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                Text(L("التواصل", "Contact"))
                    .font(.title2.bold())

                Text(L(
                    "إذا احتجت مساعدة أو كان لديك استفسار، تواصل معنا عبر البريد التالي:",
                    "If you need help or have a question, contact us via email:"
                ))
                .foregroundColor(.secondary)

                Text(contactEmail)
                    .font(.headline)
                    .textSelection(.enabled)

                Text(L(
                    "ملاحظة: سيتم الرد حسب أوقات العمل.",
                    "Note: Replies may be sent during business hours."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)

                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationTitle(L("اتصل بنا", "Contact Us"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

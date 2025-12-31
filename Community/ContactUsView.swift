//
//  ContactUsView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2025-12-29.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct ContactUsView: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    // ✅ Official contact email
    private let contactEmail: String = "info@halalmapprime.com"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text(L("التواصل", "Contact"))
                    .font(.title2.bold())

                Text(L(
                    "إذا احتجت مساعدة أو كان لديك استفسار، تواصل معنا عبر البريد التالي. وإذا رأيت منشورًا مخالفًا (فعالية/إعلان/لوحة المجتمع) يمكنك الإبلاغ عبر نفس البريد.",
                    "If you need help or have a question, contact us via the email below. If you see a post that violates our rules (event/ad/notice), you can report it using the same email."
                ))
                .foregroundColor(.secondary)

                // Email (tap to open mail app)
                Link(destination: URL(string: "mailto:\(contactEmail)")!) {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                        Text(contactEmail)
                            .font(.headline)
                    }
                }
                .padding(.top, 6)

                Divider().padding(.vertical, 6)

                Text(L("عند الإبلاغ عن منشور", "When reporting a post"))
                    .font(.headline)

                bulletList(items: [
                    L("اكتب عنوان الإيميل: \"بلاغ عن منشور\".", "Use the subject: “Report a post”."),
                    L("اذكر اسم المدينة + عنوان المنشور.", "Include the city and post title."),
                    L("أرسل لقطة شاشة إن أمكن.", "Attach a screenshot if possible."),
                    L("سنراجع البلاغ وقد نقوم بإزالة المحتوى أو تقييده.", "We will review and may remove or restrict the content.")
                ])
                .foregroundColor(.secondary)

                Text(L(
                    "ملاحظة: قد يتم الرد خلال أوقات العمل.",
                    "Note: Replies may be sent during business hours."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 6)

                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationTitle(L("اتصل بنا", "Contact Us"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helper
    @ViewBuilder
    private func bulletList(items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 10) {
                    Text("•")
                    Text(items[i])
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

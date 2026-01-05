//
//  AdsPrivacyView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct AdsPrivacyView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.openURL) private var openURL

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    // ✅ Updated to your real page
    private let privacyURL = URL(string: "https://www.halalmapprime.com/privacy.html")!
    // ✅ Suggested contact
    private let contactEmail = "info@halalmapprime.com"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                headerCard

                sectionTitle(L("سياسة الخصوصية", "Privacy Policy"))
                linkRow(
                    title: L("عرض سياسة الخصوصية", "Open Privacy Policy"),
                    subtitle: "halalmapprime.com/privacy.html",
                    systemImage: "hand.raised.fill"
                ) {
                    openURL(privacyURL)
                }

                sectionTitle(L("التواصل", "Contact"))
                linkRow(
                    title: L("راسلنا عبر البريد", "Email us"),
                    subtitle: contactEmail,
                    systemImage: "envelope.fill"
                ) {
                    if let url = URL(string: "mailto:\(contactEmail)") {
                        openURL(url)
                    }
                }

                linkRow(
                    title: L("الموقع الرسمي", "Official Website"),
                    subtitle: "www.halalmapprime.com",
                    systemImage: "globe"
                ) {
                    if let url = URL(string: "https://www.halalmapprime.com") {
                        openURL(url)
                    }
                }

                Divider().opacity(0.25)

                Text(L(
                    "ملاحظة: لا نبيع بياناتك. إدراجات الأماكن قد تُحفظ للمراجعة قبل الظهور (Pending).",
                    "Note: We do not sell your data. Place submissions may be saved for review before appearing (Pending)."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 4)

            }
            .padding()
        }
        .background(Color.black.opacity(0.0001))
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("الخصوصية والأمان", "Privacy & Safety"))
                .font(.title3.weight(.semibold))

            Text(L(
                "هدفنا أن تكون تجربة Halal Map Prime آمنة وواضحة. يمكنك مراجعة سياسة الخصوصية أو التواصل معنا في أي وقت.",
                "Our goal is to keep Halal Map Prime safe and transparent. You can review our privacy policy or contact us anytime."
            ))
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 6)
    }

    private func linkRow(title: String, subtitle: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
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
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

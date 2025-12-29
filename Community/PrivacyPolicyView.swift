//
//  PrivacyPolicyView.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/29/25.
//

import SwiftUI

struct PrivacyPolicyView: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text(L("سياسة الخصوصية", "Privacy Policy"))
                    .font(.title2.bold())

                Group {
                    Text(L(
                        "1) الغرض\nيتيح Halal Map Prime للمستخدمين نشر فعاليات مجتمعية داخل NY/NJ. هذه المنشورات عامة داخل التطبيق.",
                        "1) Purpose\nHalal Map Prime allows users to post community events within NY/NJ. These posts are visible to users in the app."
                    ))

                    Text(L(
                        "2) البيانات التي قد نجمعها\nعند نشر فعالية قد يتم حفظ: عنوان الفعالية، المدينة، اسم المكان، رقم الهاتف، وتاريخ النشر.",
                        "2) Data we may collect\nWhen posting an event we may store: event title, city, venue name, phone number, and timestamps."
                    ))

                    Text(L(
                        "3) كيفية استخدام البيانات\nنستخدم هذه البيانات فقط لعرض الفعالية داخل التطبيق ولتحسين تجربة المستخدم ومنع إساءة الاستخدام.",
                        "3) How we use data\nWe use this data to display events in the app, improve user experience, and help prevent abuse."
                    ))

                    Text(L(
                        "4) المحتوى والمسؤولية\nالمستخدم مسؤول عن صحة ما ينشره. يمنع نشر محتوى غير قانوني أو مسيء أو مضلل أو ينتهك حقوق الآخرين.",
                        "4) Content & responsibility\nUsers are responsible for what they post. Illegal, abusive, misleading, or rights-infringing content is not allowed."
                    ))

                    Text(L(
                        "5) الإزالة والتعديل\nيجوز لنا إزالة أو تقييد أي منشور يخالف الشروط أو قد يسبب ضرراً للمستخدمين أو يخالف سياسات المتجر.",
                        "5) Removal & moderation\nWe may remove or restrict any post that violates our rules, may harm users, or conflicts with store policies."
                    ))

                    Text(L(
                        "6) التواصل\nللاستفسارات: info.halalmapprime.com",
                        "6) Contact\nFor questions: info.halalmapprime.com"
                    ))
                    .foregroundColor(.secondary)
                }
                .font(.body)

                Spacer(minLength: 22)
            }
            .padding()
        }
        .navigationTitle(L("الخصوصية", "Privacy"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

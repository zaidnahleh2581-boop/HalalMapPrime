//
//  PrivacyPolicyView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2025-12-29.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct PrivacyPolicyView: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    private let lastUpdatedEN = "Last updated: December 2025"
    private let lastUpdatedAR = "آخر تحديث: ديسمبر 2025"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text(L("سياسة الخصوصية", "Privacy Policy"))
                    .font(.title2.bold())

                Text(L(lastUpdatedAR, lastUpdatedEN))
                    .foregroundColor(.secondary)
                    .font(.footnote)

                // MARK: - 1) Overview
                sectionTitle(L("1) نظرة عامة", "1) Overview"))
                paragraph(L(
                    "Halal Map Prime هو تطبيق يعتمد على الموقع لمساعدة المستخدمين على اكتشاف الأماكن والخدمات والفعاليات والإعلانات المجتمعية داخل NY/NJ. نحن نحترم خصوصيتك ونلتزم بحماية بياناتك.",
                    "Halal Map Prime is a location-based app that helps users discover halal places, services, and community content (events/ads/notices) in NY/NJ. We respect your privacy and are committed to protecting your information."
                ))

                // MARK: - 2) Information We Collect
                sectionTitle(L("2) المعلومات التي قد نجمعها", "2) Information We Collect"))
                bulletList(items: [
                    L("بيانات الموقع (اختياري): نستخدم موقعك فقط لعرض النتائج القريبة منك (مثلاً ضمن 5 أميال).", "Location data (optional): Used to show nearby results (e.g., within ~5 miles)."),
                    L("مدخلات البحث: كلمات البحث التي تكتبها داخل التطبيق لعرض نتائج مناسبة.", "Search inputs: Queries you type in the app to return relevant results."),
                    L("محتوى يقوم المستخدم بنشره: مثل عنوان الفعالية/الإعلان، الوصف، المدينة، اسم المكان، رقم هاتف التواصل، والتاريخ/الوقت.", "User-generated content: such as event/ad title, description, city, venue name, contact phone, date/time."),
                    L("بيانات الحساب (إن وُجدت): مثل رقم الهاتف/المعرف عند استخدام تسجيل الدخول أو التحقق.", "Account data (if used): such as phone number/identifier when using sign-in or verification."),
                    L("بيانات تقنية وتشخيصية: مثل سجلات الأخطاء ومعلومات الجهاز لتحسين الاستقرار ومنع إساءة الاستخدام.", "Technical & diagnostic data: such as crash logs and device info to improve stability and prevent abuse.")
                ])

                // MARK: - 3) How We Use Data
                sectionTitle(L("3) كيف نستخدم البيانات", "3) How We Use Information"))
                bulletList(items: [
                    L("عرض الأماكن والخدمات القريبة بناءً على موقعك (عند السماح بذلك).", "Show nearby places/services based on your location (when permitted)."),
                    L("عرض وتنظيم المحتوى المجتمعي (فعاليات/إعلانات/إشعارات) داخل التطبيق.", "Display and organize community content (events/ads/notices) in the app."),
                    L("التحقق من الجودة ومنع السبام وإساءة الاستخدام وحماية المستخدمين.", "Detect spam, prevent abuse, and keep the community safe."),
                    L("تحسين تجربة المستخدم والأداء وإصلاح الأعطال.", "Improve user experience, performance, and reliability.")
                ])

                // MARK: - 4) Location Privacy (Important)
                sectionTitle(L("4) خصوصية الموقع (مهم)", "4) Location Privacy (Important)"))
                paragraph(L(
                    "الموقع اختياري. إذا سمحت بالوصول للموقع، يتم استخدامه لعرض النتائج القريبة في الوقت الحقيقي. لا نقوم ببيع بيانات الموقع. ما لم نذكر خلاف ذلك، لا يتم تخزين موقعك الدقيق كـ تاريخ تنقل داخل التطبيق.",
                    "Location access is optional. If you grant location permission, we use it to show nearby results in real time. We do not sell location data. Unless otherwise stated, we do not store your precise location as a history of movements."
                ))
                bulletList(items: [
                    L("يمكنك إيقاف الموقع في أي وقت من إعدادات جهازك.", "You can disable location at any time in your device settings."),
                    L("قد لا تعمل بعض الميزات (مثل النتائج القريبة) بدون الموقع.", "Some features (like nearby results) may not work without location.")
                ])

                // MARK: - 5) Sharing & Service Providers
                sectionTitle(L("5) مشاركة البيانات ومزودو الخدمة", "5) Data Sharing & Service Providers"))
                paragraph(L(
                    "نحن لا نبيع بياناتك. قد نشارك بيانات محدودة فقط مع مزودين تقنيين لتشغيل التطبيق (مثل خدمات الاستضافة وقاعدة البيانات والمصادقة). يتم ذلك بهدف تشغيل الخدمة وتحسينها وليس لأغراض تسويق طرف ثالث.",
                    "We do not sell your data. We may share limited information with service providers that help us operate the app (e.g., hosting, database, authentication). This is for providing and improving the service, not for third-party marketing."
                ))
                bulletList(items: [
                    L("قد نستخدم خدمات مثل Firebase (Google) لتخزين المحتوى وتشغيل تسجيل الدخول وتحسين الاستقرار.", "We may use services such as Firebase (Google) for storing content, authentication, and app reliability.")
                ])

                // MARK: - 6) User Content, Rules, and Moderation
                sectionTitle(L("6) محتوى المستخدم والقواعد والإشراف", "6) User Content, Rules & Moderation"))
                paragraph(L(
                    "المستخدم مسؤول عن صحة ما ينشره. يمنع نشر محتوى غير قانوني أو مسيء أو احتيالي أو مضلل أو ينتهك حقوق الآخرين أو سياسات المتجر. يجوز لنا إزالة أو إخفاء أو تقييد أي منشور وفق تقديرنا لحماية المجتمع أو الالتزام بسياسات Apple.",
                    "Users are responsible for what they post. Illegal, abusive, fraudulent, misleading, rights-infringing content, or content that violates store policies is not allowed. We may remove, hide, or restrict content at our discretion to protect the community and comply with Apple policies."
                ))

                // MARK: - 7) Data Retention
                sectionTitle(L("7) مدة الاحتفاظ بالبيانات", "7) Data Retention"))
                paragraph(L(
                    "نحتفظ بالمحتوى المنشور والبيانات المرتبطة به طالما كان ضروريًا لتشغيل التطبيق أو الامتثال للالتزامات القانونية أو منع إساءة الاستخدام. قد يتم حذف أو أرشفة بعض المحتوى تلقائيًا بعد فترة (مثل الإعلانات/الإشعارات القديمة).",
                    "We retain posted content and related data as needed to operate the app, comply with legal obligations, and prevent abuse. Some content may be automatically removed or archived after a period (e.g., older notices/ads)."
                ))

                // MARK: - 8) Your Choices & Rights
                sectionTitle(L("8) خياراتك وحقوقك", "8) Your Choices & Rights"))
                bulletList(items: [
                    L("إيقاف صلاحية الموقع من إعدادات الجهاز.", "Disable location permission in device settings."),
                    L("طلب إزالة منشور: يمكنك التواصل معنا لإزالة محتوى مخالف أو خاص بك عند الحاجة.", "Request removal: Contact us to remove content (e.g., your post or policy-violating content)."),
                    L("قد تتوفر خيارات إضافية لحذف الحساب/البيانات داخل التطبيق حسب الميزات المفعلة.", "Additional options for deleting an account/data may be available in-app depending on enabled features.")
                ])

                // MARK: - 9) Security
                sectionTitle(L("9) أمان البيانات", "9) Data Security"))
                paragraph(L(
                    "نتخذ إجراءات تقنية وتنظيمية معقولة لحماية البيانات، لكن لا توجد طريقة نقل أو تخزين آمنة 100%.",
                    "We use reasonable technical and organizational measures to protect data, but no method of transmission or storage is 100% secure."
                ))

                // MARK: - 10) Children
                sectionTitle(L("10) خصوصية الأطفال", "10) Children’s Privacy"))
                paragraph(L(
                    "التطبيق غير مخصص للأطفال دون 13 عامًا. إذا كنت ولي أمر وتعتقد أن طفلك زودنا ببيانات، يرجى التواصل معنا لحذفها.",
                    "The app is not intended for children under 13. If you are a parent/guardian and believe your child provided data, contact us to request deletion."
                ))

                // MARK: - 11) Changes
                sectionTitle(L("11) التغييرات على هذه السياسة", "11) Changes to This Policy"))
                paragraph(L(
                    "قد نقوم بتحديث هذه السياسة من وقت لآخر. سنقوم بتعديل تاريخ “آخر تحديث” عند نشر أي تغييرات.",
                    "We may update this policy from time to time. We will revise the “Last updated” date when changes are posted."
                ))

                // MARK: - 12) Contact
                sectionTitle(L("12) التواصل", "12) Contact"))
                paragraph(L(
                    "للاستفسارات أو طلب إزالة محتوى، تواصل معنا:\nEmail: info@halalmapprime.com\nWebsite: halalmapprime.com/privacy",
                    "For questions or content removal requests, contact us:\nEmail: info@halalmapprime.com\nWebsite: halalmapprime.com/privacy"
                ))
                .foregroundColor(.secondary)

                Spacer(minLength: 22)
            }
            .padding()
        }
        .navigationTitle(L("الخصوصية", "Privacy"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - UI Helpers

    @ViewBuilder
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 6)
    }

    @ViewBuilder
    private func paragraph(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func bulletList(items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 10) {
                    Text("•")
                        .font(.body)
                    Text(items[i])
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

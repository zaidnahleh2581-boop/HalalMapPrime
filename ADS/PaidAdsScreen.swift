//
//  PaidAdsScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import StoreKit

struct PaidAdsScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var purchase = PurchaseManager.shared

    @State private var showDetailsAfterPurchase = false
    @State private var purchasedPlan: PaidPlan? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {

                Text(L("إعلانات مدفوعة", "Paid Ads"))
                    .font(.largeTitle.bold())
                    .padding(.top, 6)

                Text(L(
                    "اختر الباقة واضغط شراء. سيتم الدفع مباشرة عبر Apple App Store.",
                    "Pick a plan and tap Buy. Payment happens directly through Apple App Store."
                ))
                .font(.subheadline)
                .foregroundColor(.secondary)

                if purchase.isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                        .padding(.vertical, 16)
                }

                if let err = purchase.lastError, !err.isEmpty {
                    errorCard(err)
                }

                // ✅ بطاقتين فقط (Weekly + Prime)
                planCard(.weekly, product: purchase.product(for: IAPProducts.weeklyAd))
                planCard(.prime, product: purchase.product(for: IAPProducts.primeAd))

                Text(L(
                    "ملاحظة: لا يوجد دفع ببطاقات داخل التطبيق. كل شيء يتم عبر Apple.",
                    "Note: No card payments inside the app. Everything is via Apple."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 8)

                Spacer(minLength: 10)
            }
            .padding()
        }
        .navigationTitle(L("إعلانات مدفوعة", "Paid Ads"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // تحميل المنتجات أول ما تفتح الشاشة
            if purchase.products.isEmpty {
                await purchase.loadProducts()
            }
        }
        .sheet(isPresented: $showDetailsAfterPurchase) {
            // (مرحلة لاحقة) هنا راح نفتح فورم تفاصيل الإعلان بعد الدفع
            // حالياً نخليه شاشة بسيطة جاهزة للمرحلة التالية
            PaidAdAfterPurchaseStubView(plan: purchasedPlan ?? .weekly)
                .environmentObject(lang)
        }
    }

    // MARK: - UI

    private func planCard(_ plan: PaidPlan, product: Product?) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: plan.icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(plan.tint.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(L(plan.titleAR, plan.titleEN))
                        .font(.headline)

                    Text(L(plan.subtitleAR, plan.subtitleEN))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider().opacity(0.3)

            Text(L(plan.descriptionAR, plan.descriptionEN))
                .font(.subheadline)
                .foregroundColor(.secondary)

            // السعر واضح جدًا
            HStack {
                Text(L("السعر:", "Price:"))
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text(product?.displayPrice ?? L("غير متاح الآن", "Not available"))
                    .font(.headline)
            }
            .padding(.top, 2)

            Button {
                Task {
                    guard let product else {
                        purchase.lastError = L(
                            "المنتج غير متاح. تأكد من App Store Connect ومن الـ Product ID.",
                            "Product not available. Check App Store Connect and Product ID."
                        )
                        return
                    }

                    purchasedPlan = plan
                    let ok = await purchase.purchase(product)

                    if ok {
                        // ✅ بعد الدفع: نفتح شاشة المرحلة التالية (تفاصيل الإعلان)
                        showDetailsAfterPurchase = true
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text(L("شراء الآن", "Buy now"))
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(plan.tint.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L("مشكلة", "Issue"))
                .font(.footnote.weight(.semibold))
            Text(message)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.red.opacity(0.10)))
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}

// MARK: - Plans

private enum PaidPlan {
    case weekly
    case prime

    var icon: String {
        switch self {
        case .weekly: return "creditcard.fill"
        case .prime: return "sparkles"
        }
    }

    var tint: Color {
        switch self {
        case .weekly: return .blue
        case .prime: return .orange
        }
    }

    var titleAR: String {
        switch self {
        case .weekly: return "إعلان أسبوعي"
        case .prime: return "Prime Ad (أفضل ظهور)"
        }
    }

    var titleEN: String {
        switch self {
        case .weekly: return "Weekly Ad"
        case .prime: return "Prime Ad (Best visibility)"
        }
    }

    var subtitleAR: String {
        switch self {
        case .weekly: return "ظهور قوي لمدة ٧ أيام"
        case .prime: return "أقوى ظهور + أولوية أعلى"
        }
    }

    var subtitleEN: String {
        switch self {
        case .weekly: return "Strong visibility for 7 days"
        case .prime: return "Top visibility + higher priority"
        }
    }

    var descriptionAR: String {
        switch self {
        case .weekly:
            return "يظهر إعلانك داخل التطبيق مع ترتيب جيد ضمن التدوير."
        case .prime:
            return "أفضل خيار لأصحاب الأعمال الذين يريدون ظهوراً أعلى داخل التطبيق."
        }
    }

    var descriptionEN: String {
        switch self {
        case .weekly:
            return "Your ad shows in the app with solid ranking in rotation."
        case .prime:
            return "Best choice for businesses that want top placement inside the app."
        }
    }
}

// MARK: - After Purchase (Stub for Stage 2)

private struct PaidAdAfterPurchaseStubView: View {

    @EnvironmentObject var lang: LanguageManager
    let plan: PaidPlan

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 46))
                    .foregroundColor(.green)

                Text(L("تم الدفع بنجاح ✅", "Payment successful ✅"))
                    .font(.title3.bold())

                Text(L(
                    "الخطوة القادمة: سنفتح فورم تفاصيل الإعلان (اسم المحل، المدينة، صورة...) ونحفظه في Firestore.",
                    "Next: We'll open an ad details form (name, city, image...) and save it to Firestore."
                ))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                Text(L("الباقة:", "Plan:"))
                    .font(.headline)

                Text(lang.isArabic ? plan.titleAR : plan.titleEN)
                    .font(.headline)
                    .padding(.bottom, 6)

                Spacer()
            }
            .padding()
            .navigationTitle(L("بعد الدفع", "After purchase"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }
}
\

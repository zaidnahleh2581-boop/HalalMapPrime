//
//  AdPlanDetailsView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import StoreKit

enum AdPlan: CaseIterable, Hashable {
    case weekly
    case monthly
    case prime

    var productId: String {
        switch self {
        case .weekly: return "weekly_ad"
        case .monthly: return "monthly_ad"
        case .prime: return "prime_ad"
        }
    }

    func title(lang: LanguageManager) -> String {
        if lang.isArabic {
            switch self {
            case .weekly: return "إعلان أسبوعي"
            case .monthly: return "إعلان شهري (مميز)"
            case .prime: return "Prime Ads (أفضل ظهور)"
            }
        } else {
            switch self {
            case .weekly: return "Weekly Ad"
            case .monthly: return "Monthly Ad (Featured)"
            case .prime: return "Prime Ads (Top Visibility)"
            }
        }
    }

    func subtitle(lang: LanguageManager) -> String {
        if lang.isArabic {
            switch self {
            case .weekly: return "مدة 7 أيام • ظهور أعلى من العادي"
            case .monthly: return "مدة 30 يوم • أولوية أعلى"
            case .prime: return "أعلى أولوية • أفضل أماكن ظهور"
            }
        } else {
            switch self {
            case .weekly: return "7 days • Higher visibility"
            case .monthly: return "30 days • Higher priority"
            case .prime: return "Top priority • Best placements"
            }
        }
    }

    func shortWhereItShows(lang: LanguageManager) -> String {
        if lang.isArabic {
            switch self {
            case .weekly:
                return "يظهر إعلانك ضمن التدوير داخل التطبيق + أولوية أعلى على الخريطة."
            case .monthly:
                return "يظهر إعلانك لمدة 30 يوم مع ترتيب أعلى في النتائج والخريطة."
            case .prime:
                return "يظهر إعلانك في أعلى الظهور + بانر مميز + أفضل ترتيب."
            }
        } else {
            switch self {
            case .weekly:
                return "Your ad appears in rotation inside the app + higher map priority."
            case .monthly:
                return "Your ad appears for 30 days with higher ranking in results & map."
            case .prime:
                return "Top exposure + featured banner + highest ranking."
            }
        }
    }

    func detailsBullets(lang: LanguageManager) -> [String] {
        if lang.isArabic {
            switch self {
            case .weekly:
                return [
                    "مدة الإعلان: 7 أيام",
                    "أولوية أعلى من الإضافة العادية",
                    "مناسب للعروض الأسبوعية والفعاليات"
                ]
            case .monthly:
                return [
                    "مدة الإعلان: 30 يوم",
                    "أولوية أعلى من الأسبوعي",
                    "مناسب للمحلات اللي بدها ثبات ظهور"
                ]
            case .prime:
                return [
                    "أعلى أولوية في الظهور",
                    "بانر مميز داخل التطبيق",
                    "أفضل خيار للتسويق القوي"
                ]
            }
        } else {
            switch self {
            case .weekly:
                return [
                    "Ad duration: 7 days",
                    "Higher priority than normal listing",
                    "Great for weekly promos & events"
                ]
            case .monthly:
                return [
                    "Ad duration: 30 days",
                    "Higher priority than weekly",
                    "Great for steady visibility"
                ]
            case .prime:
                return [
                    "Highest visibility priority",
                    "Featured banner inside the app",
                    "Best choice for maximum exposure"
                ]
            }
        }
    }
}



    private func infoCard(title: String, text: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title).font(.headline)
                Spacer()
            }
            Text(text)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }

    private func infoCard(title: String, bullets: [String], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title).font(.headline)
                Spacer()
            }
            ForEach(bullets, id: \.self) { b in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(b)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }


// MARK: - Final Step: Payment (StoreKit)

struct AdPlanPaymentView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    let plan: AdPlan

    @StateObject private var purchaseManager = PurchaseManager()

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        VStack(spacing: 14) {

            VStack(alignment: .leading, spacing: 6) {
                Text(L("الدفع", "Payment"))
                    .font(.title2.bold())

                Text(L(
                    "هذه هي الخطوة الأخيرة. إذا فشل التحميل، اضغط إعادة المحاولة.",
                    "This is the final step. If loading fails, tap Retry."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if purchaseManager.isLoading {
                ProgressView()
                    .padding(.top, 14)
            } else if let err = purchaseManager.errorMessage {
                VStack(alignment: .leading, spacing: 10) {
                    Text(L("مشكلة في التحميل", "Loading issue"))
                        .font(.headline)

                    Text(err)
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Button {
                        Task { await purchaseManager.loadProduct(for: plan.productId) }
                    } label: {
                        Text(L("إعادة المحاولة", "Retry"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.08))
                )
            } else if let product = purchaseManager.product {
                VStack(alignment: .leading, spacing: 10) {
                    Text(plan.title(lang: lang))
                        .font(.headline)

                    HStack {
                        Text(product.displayPrice)
                            .font(.title3.bold())
                        Spacer()
                    }

                    Button {
                        Task { await purchaseManager.purchase(product) }
                    } label: {
                        Text(L("ادفع الآن", "Pay Now"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)

                    if let msg = purchaseManager.purchaseMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                )
            } else {
                // No product + no error + not loading (shouldn't happen often)
                Text(L("لم يتم العثور على المنتج.", "Product not found."))
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Button {
                    Task { await purchaseManager.loadProduct(for: plan.productId) }
                } label: {
                    Text(L("تحميل", "Load"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
            }

            Spacer()

        }
        .padding()
        .navigationTitle(L("الدفع", "Payment"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L("إغلاق", "Close")) { dismiss() }
            }
        }
        .onAppear {
            Task { await purchaseManager.loadProduct(for: plan.productId) }
        }
    }
}

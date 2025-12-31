//
//  MonthlyEventPaywallView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-30.
//  Updated by ChatGPT on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import StoreKit

struct MonthlyEventPaywallView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    /// Callback بعد الدفع الناجح
    var onPaid: (String) -> Void

    @StateObject private var iap = IAPManager.shared

    @State private var isBuying: Bool = false
    @State private var errorMessage: String? = nil

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    // ✅ Banner Image (from Assets)
                    Image("paid_event_banner")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(18)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // 🔒 Lock icon
                    Image(systemName: "lock.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.orange)
                        .padding(.top, 4)

                    // Title
                    Text(L(
                        "لقد استخدمت الإعلان المجاني لهذا الشهر",
                        "You already used your free monthly post"
                    ))
                    .font(.headline)
                    .multilineTextAlignment(.center)

                    // Subtitle
                    Text(L(
                        "يمكنك ترقية هذا الإعلان ونشره فوراً ليظهر للمستخدمين.",
                        "You can upgrade this post and publish it immediately to users."
                    ))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                    // Price
                    Group {
                        if let product = iap.eventPostProduct {
                            Text(L("السعر", "Price") + ": " + product.displayPrice)
                                .font(.subheadline.weight(.semibold))
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(.top, 6)

                    // Error
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 6)
                    }

                    // Buttons
                    VStack(spacing: 12) {

                        Button {
                            Task { await buy() }
                        } label: {
                            HStack {
                                if isBuying {
                                    ProgressView()
                                }
                                Text(L("ادفع وانشر الآن", "Pay & Publish Now"))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isBuying || iap.eventPostProduct == nil)

                        Button(role: .cancel) {
                            dismiss()
                        } label: {
                            Text(L("إلغاء", "Cancel"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isBuying)
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle(L("ترقية الإعلان", "Upgrade Post"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                    .disabled(isBuying)
                }
            }
            .task {
                // تحميل منتجات StoreKit عند فتح الشاشة
                await iap.loadProducts()
            }
        }
    }

    // MARK: - Purchase

    @MainActor
    private func buy() async {
        isBuying = true
        errorMessage = nil

        do {
            let paymentRef = try await iap.purchaseEventPost()
            onPaid(paymentRef)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isBuying = false
    }
}

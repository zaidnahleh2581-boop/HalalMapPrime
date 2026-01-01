//
//  PurchaseManager.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-01.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import StoreKit
import Combine

@MainActor
final class PurchaseManager: ObservableObject {

    static let shared = PurchaseManager()

    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var lastError: String? = nil

    // آخر عملية شراء ناجحة (مفيدة لفتح شاشة تفاصيل الإعلان)
    @Published var lastPurchasedProductId: String? = nil
    @Published var lastTransactionId: String? = nil

    private init() { }

    func loadProducts() async {
        lastError = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await Product.products(for: IAPProducts.all)

            // ترتيب ثابت: Weekly ثم Prime (أو العكس حسب رغبتك)
            self.products = fetched.sorted { a, b in
                let order: [String: Int] = [
                    IAPProducts.weeklyAd: 0,
                    IAPProducts.primeAd: 1
                ]
                return (order[a.id] ?? 999) < (order[b.id] ?? 999)
            }

        } catch {
            lastError = error.localizedDescription
        }
    }

    func product(for id: String) -> Product? {
        products.first(where: { $0.id == id })
    }

    /// شراء منتج
    func purchase(_ product: Product) async -> Bool {
        lastError = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    lastPurchasedProductId = transaction.productID
                    lastTransactionId = String(transaction.id)
                    await transaction.finish()
                    return true

                case .unverified(_, let error):
                    lastError = error.localizedDescription
                    return false
                }

            case .userCancelled:
                return false

            case .pending:
                lastError = "Payment is pending."
                return false

            @unknown default:
                lastError = "Unknown purchase result."
                return false
            }

        } catch {
            lastError = error.localizedDescription
            return false
        }
    }
}

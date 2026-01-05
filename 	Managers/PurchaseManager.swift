//
//  PurchaseManager.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2026-01-04.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import Combine
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {

    @Published var product: Product? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var purchaseMessage: String? = nil

    func loadProduct(for productId: String) async {
        isLoading = true
        errorMessage = nil
        purchaseMessage = nil
        product = nil

        do {
            let loaded = try await Product.products(for: [productId])
            self.product = loaded.first
            self.isLoading = false

            if self.product == nil {
                self.errorMessage = "No product returned for id: \(productId)"
            }
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        purchaseMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success:
                purchaseMessage = "✅ Purchase success"
            case .userCancelled:
                purchaseMessage = "User cancelled"
            case .pending:
                purchaseMessage = "Purchase pending"
            @unknown default:
                purchaseMessage = "Unknown purchase state"
            }
        } catch {
            purchaseMessage = error.localizedDescription
        }
    }
}

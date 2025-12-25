//
//  HomeCategoriesGrid.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct HomeCategoriesGrid: View {

    @EnvironmentObject var lang: LanguageManager

    /// عندما يضغط المستخدم على Category
    let onSelect: (PlaceCategory) -> Void

    @State private var showMoreSheet: Bool = false

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    // ✅ Primary core categories (always visible) - includes Mosques
    private var primary: [PlaceCategory] {
        [.restaurant, .foodTruck, .grocery, .mosque]
    }

    // ✅ Secondary categories (shown in sheet)
    private var secondary: [PlaceCategory] {
        [.school, .service, .market, .shop, .center]
    }

    private let sheetColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header + More
            HStack {
                Text(L("التصنيفات", "Categories"))
                    .font(.headline)

                Spacer()

                Button {
                    showMoreSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Text(L("المزيد", "More"))
                            .font(.subheadline.bold())
                        Image(systemName: "chevron.right")
                            .font(.subheadline.bold())
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            // ✅ Yelp-like primary row (small chips)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(primary) { category in
                        chip(category: category) {
                            onSelect(category)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 2)
            }
        }
        .sheet(isPresented: $showMoreSheet) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {

                        Text(L("كل التصنيفات", "All categories"))
                            .font(.title3.bold())
                            .padding(.horizontal)
                            .padding(.top, 8)

                        LazyVGrid(columns: sheetColumns, spacing: 12) {
                            ForEach(secondary) { category in
                                sheetCard(category: category) {
                                    showMoreSheet = false
                                    onSelect(category)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 18)
                    }
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle(L("التصنيفات", "Categories"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(L("إغلاق", "Close")) { showMoreSheet = false }
                    }
                }
            }
        }
    }

    // MARK: - Yelp-like chip

    private func chip(category: PlaceCategory, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(accent(for: category).opacity(0.15))
                        .frame(width: 34, height: 34)

                    Image(systemName: icon(for: category))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(accent(for: category))
                }

                Text(title(for: category))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.systemBackground))
            .cornerRadius(999)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sheet cards

    private func sheetCard(category: PlaceCategory, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accent(for: category).opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon(for: category))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(accent(for: category))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title(for: category))
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)

                    Text(L("اضغط لعرض الأماكن", "Tap to view places"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func title(for category: PlaceCategory) -> String {
        switch category {
        case .restaurant: return L("مطاعم", "Restaurants")
        case .foodTruck:  return L("فود ترك", "Food Trucks")
        case .grocery:    return L("بقالات", "Groceries")
        case .mosque:     return L("مساجد", "Mosques")
        case .school:     return L("مدارس", "Schools")
        case .service:    return L("خدمات", "Services")
        case .market:     return L("ماركت", "Markets")
        case .shop:       return L("محلات", "Shops")
        case .center:     return L("مراكز", "Centers")
        }
    }

    private func icon(for category: PlaceCategory) -> String {
        switch category {
        case .restaurant: return "fork.knife"
        case .foodTruck:  return "truck.box.fill"
        case .grocery:    return "cart.fill"
        case .mosque:     return "moon.stars.fill"
        case .school:     return "book.fill"
        case .service:    return "wrench.and.screwdriver.fill"
        case .market:     return "basket.fill"
        case .shop:       return "bag.fill"
        case .center:     return "building.2.fill"
        }
    }

    private func accent(for category: PlaceCategory) -> Color {
        switch category {
        case .restaurant: return .orange
        case .foodTruck:  return .red
        case .grocery:    return .green
        case .mosque:     return .blue
        default:
            return .gray
        }
    }
}

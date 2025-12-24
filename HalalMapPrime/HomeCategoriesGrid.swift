//
//  HomeCategoriesGrid.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct HomeCategoriesGrid: View {

    @EnvironmentObject var lang: LanguageManager

    /// ✅ عندما يضغط المستخدم على Category
    let onSelect: (PlaceCategory) -> Void

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(L("التصنيفات", "Categories"))
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {

                // 🥇 Restaurants
                categoryCard(
                    icon: "fork.knife",
                    title: L("مطاعم", "Restaurants"),
                    accent: .orange
                ) {
                    onSelect(.restaurant)
                }

                // 🥈 Food Trucks (لو عندك Category مخصصة للفود ترك غيّرها)
                categoryCard(
                    icon: "car.fill",
                    title: L("فود ترك", "Food Trucks"),
                    accent: .red
                ) {
                    // إن لم يكن عندك foodTruck في PlaceCategory خلّيه restaurant مؤقتاً
                    onSelect(.restaurant)
                }

                // 🥉 Halal Stores
                categoryCard(
                    icon: "cart.fill",
                    title: L("متاجر حلال", "Halal Stores"),
                    accent: .green
                ) {
                    onSelect(.grocery)
                }

                // 🔥 Jobs (ذهب) — هنا ليس خريطة، لاحقاً نربطه لشاشة Jobs
                categoryCard(
                    icon: "briefcase.fill",
                    title: L("وظائف", "Jobs"),
                    accent: .blue
                ) {
                    // مؤقتاً: نفتح CommunityHubScreen أو JobAdsBoardView لاحقاً
                    // الآن خلّيها تفتح خريطة مطاعم مؤقتاً أو لا تعمل شيء
                    // الأفضل: نربطها لشاشة Jobs بالمرحلة التالية
                }

                // 📢 Community — لاحقاً نربطه لصفحة Community
                categoryCard(
                    icon: "person.3.fill",
                    title: L("المجتمع", "Community"),
                    accent: .teal
                ) {
                    // لاحقاً
                }

                // 🕌 Masjid (Last)
                categoryCard(
                    icon: "moon.stars.fill",
                    title: L("مساجد", "Masjid"),
                    accent: .purple
                ) {
                    onSelect(.mosque)
                }
            }
            .padding(.horizontal)
        }
    }

    private func categoryCard(
        icon: String,
        title: String,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(accent)

                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

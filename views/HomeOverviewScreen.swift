//
//  HomeOverviewScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct HomeOverviewScreen: View {

    @EnvironmentObject var lang: LanguageManager

    enum HomeRoute: Hashable {
        case category(PlaceCategory)
    }

    @State private var path: [HomeRoute] = []
    @State private var adIndex: Int = 0
    @State private var searchText: String = ""

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // 1) Yelp-like search
                    searchBar
                        .padding(.horizontal)
                        .padding(.top, 6)

                    // 2) Categories (keep your original, but visually lighter)
                    categoriesSection

                    // 3) Featured Ad (ONE big swipe carousel)
                    featuredAdCarousel

                    // 4) Jobs Near You (chips, not dead text)
                    jobsNearYouChips
                }
                .padding(.bottom, 18)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(L("الرئيسية", "Home"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .category(let category):
                    MapScreen(startingCategory: category, hideCategoryPicker: true)
                        .environmentObject(lang)
                        .navigationTitle(category.displayName)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

// MARK: - Yelp-like pieces
private extension HomeOverviewScreen {

    var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(L("ابحث عن مطعم، مسجد، بقالة...", "Search restaurants, mosques, groceries..."), text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(L("التصنيفات", "Categories"))
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            // ✅ keep your existing grid logic (More expand/collapse)
            // BUT: visually reduce vertical padding in the cards (handled in HomeCategoriesGrid if you want later)
            HomeCategoriesGrid { category in
                path.append(.category(category))
            }
            .environmentObject(lang)
            .padding(.top, 2)
        }
    }

    var featuredAdCarousel: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(L("إعلان مميز", "Featured Ad"))
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            TabView(selection: $adIndex) {
                ForEach(Array(demoBannerAds.enumerated()), id: \.offset) { index, ad in
                    featuredAdCard(ad)
                        .tag(index)
                        .padding(.horizontal)
                }
            }
            .frame(height: 200)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }

    func featuredAdCard(_ ad: BannerAd) -> some View {
        ZStack(alignment: .bottomLeading) {

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)

            // “Fake image” placeholder using big icon (until you add real images)
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemGray6))

                Image(systemName: ad.imageSystemName)
                    .font(.system(size: 54, weight: .bold))
                    .foregroundColor(.orange.opacity(0.9))
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(ad.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(ad.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(tagText(for: ad.categoryAudience))
                    .font(.caption2.bold())
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.orange.opacity(0.16))
                    .foregroundColor(.orange)
                    .clipShape(Capsule())
                    .padding(.top, 4)
            }
            .padding(14)
            .background(
                // nice Yelp-like gradient overlay
                LinearGradient(
                    colors: [
                        Color(.systemBackground).opacity(0.92),
                        Color(.systemBackground).opacity(0.75),
                        Color(.systemBackground).opacity(0.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            )
        }
        .frame(height: 200)
    }

    func tagText(for audience: AdAudience) -> String {
        switch audience {
        case .restaurants: return L("مطاعم / فود ترك", "Restaurants / Food Trucks")
        case .mosques:     return L("مساجد", "Mosques")
        case .shops:       return L("متاجر", "Shops")
        case .schools:     return L("مدارس", "Schools")
        }
    }

    var jobsNearYouChips: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(L("وظائف قربك اليوم", "Jobs Near You Today"))
                    .font(.headline)
                Spacer()
                // لاحقاً نربطه فعلياً بتب الوظائف
                Text(L("عرض الكل", "See all"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {

                    jobChip(title: L("مطاعم", "Restaurants"), icon: "fork.knife", tint: .orange) {
                        // TODO later: open Jobs tab with category filter
                    }

                    jobChip(title: L("فود ترك", "Food Trucks"), icon: "truck.box.fill", tint: .red) {
                    }

                    jobChip(title: L("بقالات", "Groceries"), icon: "cart.fill", tint: .green) {
                    }

                    jobChip(title: L("مساجد", "Mosques"), icon: "moon.stars.fill", tint: .blue) {
                    }

                    jobChip(title: L("متاجر", "Shops"), icon: "bag.fill", tint: .purple) {
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }

            Text(
                L(
                    "هنا سيظهر أفضل وظائف مدفوعة + مجانية حسب منطقتك. هذا القسم سيكون من أهم أجزاء الصفحة الرئيسية.",
                    "Top paid + free jobs will appear here based on your area. This will be a core section of the Home page."
                )
            )
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(.horizontal)
        }
    }

    func jobChip(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.systemBackground))
            .cornerRadius(999)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

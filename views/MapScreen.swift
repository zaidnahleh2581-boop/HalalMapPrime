//
//  MapScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-15.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    // MARK: - State / Environment

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var viewModel = MapScreenViewModel()

    @State private var searchText: String = ""
    @State private var showResults: Bool = true
    @State private var selectedPlace: Place? = nil

    // Navigation
    @State private var showMoreCategories: Bool = false
    @State private var pushCategory: PlaceCategory? = nil

    // ✅ Top categories (4 فقط) — حسب خيار A
    private let topCategories: [PlaceCategory] = [.restaurant, .foodTruck, .market, .mosque]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {

                    // HEADER + SEARCH
                    header
                    searchBar

                    // ✅ Top Categories (4 + More)
                    topCategoryBar

                    // 🔺 إعلان Prime كبير أعلى الصفحة (إسلامي الهوية)
                    topAdsSection
                        .padding(.horizontal)

                    // 🗺 الخريطة
                    mapView

                    // 🔻 شريط متحرّك صغير لــ Prime Highlights
                    primeHighlightsCarousel
                        .padding(.horizontal)

                    // قائمة النتائج
                    if showResults {
                        resultsList
                    }
                }
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
            // ✅ صفحة الفئة (Reusable)
            .navigationDestination(item: $pushCategory) { category in
                CategoryBrowseScreen(category: category)
                    .environmentObject(lang)
            }
            // ✅ More Sheet
            .sheet(isPresented: $showMoreCategories) {
                MoreCategoriesSheet(
                    excluded: topCategories,
                    onSelect: { category in
                        showMoreCategories = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            pushCategory = category
                        }
                    }
                )
                .environmentObject(lang)
            }
        }
    }
}

// MARK: - Helper for localization
private extension MapScreen {
    func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    func localizedCategoryName(_ category: PlaceCategory) -> String {
        switch category {
        case .restaurant: return L("مطاعم", "Restaurants")
        case .foodTruck:  return L("فود ترك", "Food Trucks")
        case .market:     return L("أسواق", "Markets")
        case .mosque:     return L("مساجد", "Mosques")
        default:
            return category.displayName
        }
    }
}

// MARK: - Header / Search / Top Categories / Map / Results
private extension MapScreen {

    // هيدر بهوية إسلامية بسيطة (هلال + سطر تعريفي)
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "moon.stars.fill")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.0, green: 0.55, blue: 0.45))

                    Text(L("حلال ماب برايم", "Halal Map Prime"))
                        .font(.title3.bold())
                }

                Text(
                    L(
                        "دليلك إلى كل ما هو حلال في مدينتك",
                        "Your guide to everything halal in your city"
                    )
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(
                L("ابحث عن مكان حلال…", "Search for a halal place…"),
                text: $searchText
            )
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .onChange(of: searchText) { newValue in
                viewModel.filterBySearch(text: newValue)
            }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    viewModel.filterBySearch(text: "")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // ✅ Top Category Bar (4 + More)
    var topCategoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {

                ForEach(topCategories) { category in
                    Button {
                        pushCategory = category
                    } label: {
                        HStack(spacing: 6) {
                            Text(category.emoji)
                            Text(localizedCategoryName(category))
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }

                // More
                Button {
                    showMoreCategories = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "ellipsis.circle.fill")
                        Text(L("المزيد", "More"))
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }

    var mapView: some View {
        Map(
            coordinateRegion: $viewModel.region,
            annotationItems: viewModel.filteredPlaces
        ) { place in
            MapAnnotation(coordinate: place.coordinate) {
                VStack(spacing: 2) {
                    Text(place.category.emoji)
                        .font(.system(size: 20))
                    Circle()
                        .fill(place.category.mapColor)
                        .frame(width: 10, height: 10)
                }
                .onTapGesture {
                    selectedPlace = place
                    viewModel.focus(on: place)
                }
            }
        }
        .frame(height: 280)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    /// قائمة النتائج بدون List عشان ما يصير تعارض Scroll
    var resultsList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredPlaces) { place in
                Button {
                    selectedPlace = place
                    viewModel.focus(on: place)
                } label: {
                    PlaceRowView(place: place)
                }

                Divider()
                    .padding(.leading, 16)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - ADS / PRIME SECTIONS
private extension MapScreen {

    // 🔺 إعلان Prime كبير أعلى الصفحة – بألوان إسلامية
    var topAdsSection: some View {
        bigPrimeBanner(
            titleEN: "Featured halal prime ad",
            titleAR: "إعلان حلال مميز",
            subtitleEN: "Top visibility for your halal business in NYC & NJ.",
            subtitleAR: "أعلى ظهور لنشاطك الحلال في نيويورك ونيوجيرسي.",
            tagTextEN: "PRIME • HALAL",
            tagTextAR: "إعلان حلال • PRIME",
            logoName: nil
        )
    }

    // 🔻 شريط متحرك صغير أسفل الخريطة (Prime Highlights)
    var primeHighlightsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                smallPrimeBanner(
                    icon: "fork.knife",
                    title: L("مطاعم حلال", "Halal Restaurants"),
                    subtitle: L("أفضل الخيارات القريبة", "Top nearby picks")
                )
                smallPrimeBanner(
                    icon: "mappin.and.ellipse",
                    title: L("مساجد / Masjid", "Mosques / Masjid"),
                    subtitle: L("الصلاة والجمعة", "Prayer & Jumu’ah")
                )
                smallPrimeBanner(
                    icon: "cart.fill",
                    title: L("أسواق حلال", "Halal Markets"),
                    subtitle: L("لحوم وبقالات ومواد تموين", "Meat, groceries & more")
                )
            }
            .padding(.vertical, 4)
        }
    }

    func bigPrimeBanner(
        titleEN: String,
        titleAR: String,
        subtitleEN: String,
        subtitleAR: String,
        tagTextEN: String,
        tagTextAR: String,
        logoName: String?
    ) -> some View {
        let title = L(titleAR, titleEN)
        let subtitle1 = L(subtitleAR, subtitleEN)
        let tagText = L(tagTextAR, tagTextEN)

        return ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.30, blue: 0.23),
                    Color(red: 0.00, green: 0.55, blue: 0.50)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                .blendMode(.overlay)

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.black.opacity(0.2))
                    Image(systemName: "moon.stars.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(subtitle1)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)

                    Text(tagText)
                        .font(.caption2.bold())
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.22))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.top, 4)
                }

                Spacer()
            }
            .padding(14)
        }
        .frame(height: 120)
        .cornerRadius(22)
        .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
    }

    func smallPrimeBanner(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.bold())
            }
            .foregroundColor(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(L("Prime • Halal", "Prime • Halal"))
                .font(.caption2)
                .foregroundColor(Color(red: 0.0, green: 0.55, blue: 0.45))
        }
        .padding(10)
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

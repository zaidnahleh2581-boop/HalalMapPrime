//
//  MapScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import MapKit

struct MapScreen: View {

    // MARK: - Environment & State
    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var router: AppRouter     // ✅ NEW
    @StateObject private var viewModel = MapScreenViewModel()

    let startingCategory: PlaceCategory?
    let hideCategoryPicker: Bool

    @State private var selectedCategory: PlaceCategory? = nil
    @State private var searchText: String = ""
    @State private var showResults: Bool = true

    // ✅ Bottom Sheet تفاصيل المكان
    @State private var selectedPlace: Place? = nil

    @State private var showCategoriesRow: Bool = false

    // ✅ UX: وقت يشتغل Search
    @State private var isSearching: Bool = false
    @State private var lastSubmittedQuery: String = ""

    // MARK: - Init
    init(
        startingCategory: PlaceCategory? = nil,
        hideCategoryPicker: Bool = false
    ) {
        self.startingCategory = startingCategory
        self.hideCategoryPicker = hideCategoryPicker
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                header
                searchBar

                if !hideCategoryPicker {
                    categoryFilters
                }

                topAdsSection
                    .padding(.horizontal)

                mapView

                primeHighlightsCarousel
                    .padding(.horizontal)

                if showResults {
                    resultsList
                }
            }
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.interactively)

        // ✅ Bottom Sheet تفاصيل المكان
        .sheet(item: $selectedPlace) { place in
            PlaceDetailsSheet(place: place)
                .environmentObject(lang)
                .presentationDetents([.medium, .large])
        }

        .onAppear {
            // 1) لو في DeepLink جاهز للخريطة → طبّقه فوراً
            if let deepCat = router.pendingMapCategory {
                selectedCategory = deepCat
                viewModel.searchNearby(category: deepCat)
                viewModel.filterBySearch(text: searchText)
                router.pendingMapCategory = nil
                return
            }

            // 2) لو الشاشة انفتحت بـ startingCategory
            if let startingCategory {
                selectedCategory = startingCategory
                viewModel.searchNearby(category: startingCategory)
                viewModel.filterBySearch(text: searchText)
            } else {
                // 3) افتراضي: nearby عام
                viewModel.searchNearby(category: nil)
            }
        }

        // ✅ إذا إجالك DeepLink لاحقاً وانت على نفس الصفحة
        .onChange(of: router.pendingMapCategory) { newCat in
            guard let c = newCat else { return }
            selectedCategory = c
            viewModel.searchNearby(category: c)
            viewModel.filterBySearch(text: searchText)
            router.pendingMapCategory = nil
        }
    }
}

// MARK: - Localization Helper
private extension MapScreen {
    func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }
}

// MARK: - Actions (Real Search)
private extension MapScreen {

    func submitSearch() {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // ✅ لو نفس الكلمة انضغط Search مرة ثانية ما نعيد طلب
        if q == lastSubmittedQuery { return }
        lastSubmittedQuery = q

        // ✅ إذا فاضي: ارجع Nearby
        if q.isEmpty {
            isSearching = false
            viewModel.searchNearby(category: selectedCategory)
            viewModel.filterBySearch(text: "")
            return
        }

        // ✅ بحث حقيقي
        isSearching = true
        viewModel.searchByText(query: q, category: selectedCategory) { _ in
            DispatchQueue.main.async {
                self.isSearching = false
                self.viewModel.filterBySearch(text: self.searchText)
            }
        }
    }

    func clearSearch() {
        searchText = ""
        lastSubmittedQuery = ""
        isSearching = false
        viewModel.searchNearby(category: selectedCategory)
        viewModel.filterBySearch(text: "")
    }
}

// MARK: - UI Sections
private extension MapScreen {

    // Header
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "moon.stars.fill")
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

    // ✅ Search Bar (Real)
    var searchBar: some View {
        HStack(spacing: 10) {

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField(
                    L("ابحث عن مكان حلال…", "Search for a halal place…"),
                    text: $searchText
                )
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit { submitSearch() }
                .onChange(of: searchText) { value in
                    viewModel.filterBySearch(text: value)
                }

                if !searchText.isEmpty {
                    Button { clearSearch() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Button { submitSearch() } label: {
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.9)
                        .frame(width: 36, height: 36)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 28))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    // Categories
    var categoryFilters: some View {
        VStack(spacing: 6) {

            Button {
                withAnimation { showCategoriesRow.toggle() }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(L("التصنيفات", "Categories"))
                        .font(.subheadline.bold())
                    Spacer()
                    Image(systemName: showCategoriesRow ? "chevron.up" : "chevron.down")
                }
                .padding()
                .background(Capsule().fill(Color(.systemGray6)))
            }
            .padding(.horizontal)
            .buttonStyle(.plain)

            if showCategoriesRow {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {

                        Button {
                            selectedCategory = nil
                            viewModel.searchNearby(category: nil)
                            viewModel.filterBySearch(text: searchText)
                        } label: {
                            Text(L("الكل", "All"))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    selectedCategory == nil
                                    ? Color.blue.opacity(0.18)
                                    : Color(.systemGray6)
                                )
                                .cornerRadius(10)
                        }

                        ForEach(PlaceCategory.allCases) { category in
                            Button {
                                selectedCategory = category

                                let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !q.isEmpty {
                                    submitSearch()
                                } else {
                                    viewModel.searchNearby(category: category)
                                    viewModel.filterBySearch(text: searchText)
                                }
                            } label: {
                                Text(category.displayName)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(
                                        selectedCategory == category
                                        ? category.mapColor.opacity(0.25)
                                        : Color(.systemGray6)
                                    )
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // ✅ Map
    var mapView: some View {
        Map(
            coordinateRegion: $viewModel.region,
            annotationItems: viewModel.filteredPlaces
        ) { place in
            MapAnnotation(coordinate: place.coordinate) {
                Button {
                    selectedPlace = place
                    viewModel.focus(on: place)
                } label: {
                    VStack(spacing: 4) {
                        Text(place.category.emoji)
                        Circle()
                            .fill(place.category.mapColor)
                            .frame(width: 8, height: 8)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 280)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // ✅ Results
    var resultsList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.filteredPlaces) { place in
                Button {
                    selectedPlace = place
                } label: {
                    PlaceRowView(place: place)
                }

                Divider()
            }
        }
        .padding(.horizontal)
    }

    // ✅ Ads Placeholder
    var topAdsSection: some View {
        Text(L("إعلانات مميزة", "Featured Ads"))
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.green.opacity(0.15))
            .cornerRadius(16)
    }

    var primeHighlightsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Text("Prime • Halal")
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
}

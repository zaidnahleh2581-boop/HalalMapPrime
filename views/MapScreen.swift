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
    @StateObject private var viewModel = MapScreenViewModel()

    let startingCategory: PlaceCategory?
    let hideCategoryPicker: Bool

    @State private var selectedCategory: PlaceCategory? = nil
    @State private var searchText: String = ""
    @State private var showResults: Bool = true
    @State private var selectedPlace: Place? = nil
    @State private var showCategoriesRow: Bool = false

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

        // ✅ لا تضع NavigationStack هنا (لأن الأب أصلاً NavigationStack)
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
        .navigationDestination(item: $selectedPlace) { place in
            PlaceDetailView(place: place)
        }
        .onAppear {
            // ✅ إذا فتحت من Home وبعتنا startingCategory
            if let startingCategory {
                selectedCategory = startingCategory
                viewModel.searchNearby(category: startingCategory)
                viewModel.filterBySearch(text: searchText)
            }
        }
    }
}

// MARK: - Localization Helper
private extension MapScreen {
    func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
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

    // Search Bar
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
            .onChange(of: searchText) { value in
                viewModel.filterBySearch(text: value)
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

    // Categories
    var categoryFilters: some View {
        VStack(spacing: 6) {

            Button {
                withAnimation {
                    showCategoriesRow.toggle()
                }
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
                        ForEach(PlaceCategory.allCases) { category in
                            Button {
                                selectedCategory = category
                                viewModel.searchNearby(category: category)
                                viewModel.filterBySearch(text: searchText)
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

    // Map
    var mapView: some View {
        Map(
            coordinateRegion: $viewModel.region,
            annotationItems: viewModel.filteredPlaces
        ) { place in
            MapAnnotation(coordinate: place.coordinate) {
                VStack {
                    Text(place.category.emoji)
                    Circle()
                        .fill(place.category.mapColor)
                        .frame(width: 8, height: 8)
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

    // Results
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

    // Ads
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

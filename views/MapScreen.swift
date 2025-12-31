//
//  MapScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-30.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import MapKit

struct MapScreen: View {

    // MARK: - Environment
    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var router: AppRouter

    // MARK: - ViewModel
    @StateObject private var viewModel = MapScreenViewModel()

    // MARK: - Params
    let startingCategory: PlaceCategory?
    let hideCategoryPicker: Bool

    // MARK: - UI State
    @State private var selectedCategory: PlaceCategory? = nil
    @State private var searchText: String = ""
    @State private var selectedPlace: Place? = nil
    @State private var showCategoriesRow = false
    @State private var isSearching = false
    @State private var lastSubmittedQuery = ""

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

                mapView
                resultsList
            }
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.interactively)

        // Bottom Sheet
        .sheet(item: $selectedPlace) { place in
            PlaceDetailsSheet(place: place)
                .environmentObject(lang)
                .presentationDetents([.medium, .large])
        }

        // Initial load
        .onAppear {
            if let cat = startingCategory {
                selectedCategory = cat
                viewModel.searchNearby(category: cat)
            } else {
                viewModel.searchNearby(category: nil)
            }
        }
    }
}

// MARK: - Helpers
private extension MapScreen {
    func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }
}

// MARK: - Search Logic
private extension MapScreen {

    func submitSearch() {
        let q = searchText.trimmingCharacters(in: .whitespaces)

        if q == lastSubmittedQuery { return }
        lastSubmittedQuery = q

        if q.isEmpty {
            viewModel.searchNearby(category: selectedCategory)
            viewModel.filterBySearch(text: "")
            return
        }

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
        viewModel.searchNearby(category: selectedCategory)
        viewModel.filterBySearch(text: "")
    }
}

// MARK: - UI Sections
private extension MapScreen {

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L("حلال ماب برايم", "Halal Map Prime"))
                    .font(.title3.bold())
                Text(L("دليلك إلى الأماكن الحلال", "Your halal places guide"))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    var searchBar: some View {
        HStack(spacing: 10) {

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField(
                    L("ابحث عن مكان حلال", "Search halal place"),
                    text: $searchText
                )
                .submitLabel(.search)
                .onSubmit { submitSearch() }
                .onChange(of: searchText) {
                    viewModel.filterBySearch(text: $0)
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

            Button(action: submitSearch) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 26))
            }
        }
        .padding(.horizontal)
    }

    var categoryFilters: some View {
        VStack(spacing: 6) {

            Button {
                withAnimation { showCategoriesRow.toggle() }
            } label: {
                HStack {
                    Text(L("التصنيفات", "Categories"))
                        .font(.subheadline.bold())
                    Spacer()
                    Image(systemName: showCategoriesRow ? "chevron.up" : "chevron.down")
                }
                .padding()
                .background(Capsule().fill(Color(.systemGray6)))
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            if showCategoriesRow {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {

                        Button("All") {
                            selectedCategory = nil
                            viewModel.searchNearby(category: nil)
                        }

                        ForEach(PlaceCategory.allCases) { cat in
                            Button(cat.displayName) {
                                selectedCategory = cat
                                viewModel.searchNearby(category: cat)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    var mapView: some View {
        Map(
            coordinateRegion: $viewModel.region,
            annotationItems: viewModel.filteredPlaces
        ) { place in
            MapAnnotation(coordinate: place.coordinate) {
                Button {
                    selectedPlace = place
                } label: {
                    VStack {
                        Text(place.category.emoji)
                        Circle()
                            .fill(place.category.mapColor)
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .frame(height: 280)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    var resultsList: some View {
        VStack {
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
}

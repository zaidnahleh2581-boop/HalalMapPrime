//
//  CategoryBrowseScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-15.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import MapKit

struct CategoryBrowseScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.openURL) private var openURL

    let category: PlaceCategory

    @StateObject private var viewModel = MapScreenViewModel()
    @State private var searchText: String = ""
    @State private var selectedPlace: Place? = nil

    @State private var showShareSheet: Bool = false
    @State private var shareItems: [Any] = []

    // ✅ Loading state
    @State private var isLoading: Bool = true

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private var titleText: String {
        switch category {
        case .restaurant: return L("المطاعم", "Restaurants")
        case .foodTruck:  return L("الفود ترك", "Food Trucks")
        case .market:     return L("الأسواق", "Markets")
        case .mosque:     return L("المساجد", "Mosques")
        case .school:     return L("المدارس", "Schools")
        default:          return category.displayName
        }
    }

    // ATF: أول 8 أماكن كـ Cards
    private var featuredPlaces: [Place] {
        Array(viewModel.filteredPlaces.prefix(8))
    }

    // ✅ Empty state check (after loading)
    private var isEmptyAfterLoading: Bool {
        !isLoading && viewModel.filteredPlaces.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {

                // Search
                searchBar

                // ✅ Loading
                if isLoading {
                    loadingSection
                        .padding(.top, 12)
                }

                // ✅ Empty State
                if isEmptyAfterLoading {
                    emptyStateSection
                        .padding(.top, 12)
                }

                // ✅ Content
                if !isLoading && !viewModel.filteredPlaces.isEmpty {

                    // ATF Cards
                    if !featuredPlaces.isEmpty {
                        atfCardsSection
                    }

                    // Map
                    mapSection

                    // List
                    resultsListSection
                }
            }
            .padding(.bottom, 16)
        }
        .navigationTitle(titleText)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reloadData()
        }
        .navigationDestination(item: $selectedPlace) { place in
            PlaceDetailView(place: place)
                .environmentObject(lang)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }
}

// MARK: - Data

private extension CategoryBrowseScreen {
    func reloadData() {
        isLoading = true

        // نعمل البحث
        viewModel.searchNearby(category: category)
        viewModel.filterBySearch(text: searchText)

        // ✅ Loading بسيط (يعطي وقت للنتائج تظهر)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isLoading = false
        }
    }
}

// MARK: - UI Sections

private extension CategoryBrowseScreen {

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(L("ابحث…", "Search…"), text: $searchText)
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

    var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.1)

            Text(L("جاري تحميل الأماكن القريبة…", "Loading nearby places…"))
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(L("قد يستغرق الأمر ثوانٍ حسب الشبكة.", "This may take a few seconds depending on your network."))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }

    var emptyStateSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 44))
                .foregroundColor(.secondary)

            Text(L("لا توجد نتائج قريبة الآن", "No nearby results right now"))
                .font(.headline)

            Text(
                L(
                    "جرّب تعديل البحث أو أعد المحاولة بعد قليل.",
                    "Try changing your search, or try again in a moment."
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)

            Button {
                reloadData()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text(L("إعادة المحاولة", "Try again"))
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    var atfCardsSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(L("الأقرب إليك", "Near you"))
                    .font(.headline)

                Spacer()

                Text(L("اسحب", "Swipe"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(featuredPlaces) { place in
                        VStack(spacing: 10) {

                            Button {
                                selectedPlace = place
                                viewModel.focus(on: place)
                            } label: {
                                PlaceCardView(place: place)
                            }
                            .buttonStyle(.plain)

                            HStack(spacing: 10) {

                                Button {
                                    openDirections(to: place)
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                        Text(L("الاتجاهات", "Directions"))
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .padding(.vertical, 10)
                                    .frame(width: 125)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)

                                Button {
                                    presentShare(for: place)
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "square.and.arrow.up")
                                        Text(L("مشاركة", "Share"))
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .padding(.vertical, 10)
                                    .frame(width: 125)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 4)
    }

    var mapSection: some View {
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
        .frame(height: 300)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    var resultsListSection: some View {
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
        .padding(.top, 6)
    }

    func openDirections(to place: Place) {
        let name = urlEncoded(place.name)
        let urlString = "maps://?q=\(name)&ll=\(place.latitude),\(place.longitude)"
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }

    func presentShare(for place: Place) {
        let text = "\(place.name)\n\(place.address), \(place.cityState)"
        let urlString = "https://maps.apple.com/?q=\(urlEncoded(place.name))&ll=\(place.latitude),\(place.longitude)"
        if let url = URL(string: urlString) {
            shareItems = [text, url]
        } else {
            shareItems = [text]
        }
        showShareSheet = true
    }

    func urlEncoded(_ s: String) -> String {
        s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
    }
}

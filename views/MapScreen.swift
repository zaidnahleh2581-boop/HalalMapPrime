//
//  MapScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh
//
//
//  Search only (optional) + Categories row + Ads cards with images
//

import SwiftUI

struct MapScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var viewModel = MapScreenViewModel()
    @ObservedObject private var adsStore = AdsStore.shared

    @State private var searchText: String = ""
    @State private var selectedPlace: Place? = nil

    @State private var showMoreCategories: Bool = false
    @State private var pushCategory: PlaceCategory? = nil

    private let topCategories: [PlaceCategory] = [.restaurant, .foodTruck, .market, .mosque]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    header
                    searchBar
                    topCategoryBar

                    // ✅ Sponsored + Trending (Yelp style)
                    homeAdsSection
                        .padding(.horizontal)

                    // ✅ Search results only when typing
                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        resultsList
                            .padding(.top, 6)
                    }
                }
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationDestination(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
            .navigationDestination(item: $pushCategory) { category in
                CategoryBrowseScreen(category: category)
                    .environmentObject(lang)
            }
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
            // ✅ مهم: شغّل Listener للإعلانات
            .onAppear {
                adsStore.startActiveListener()
            }
        }
    }
}

// MARK: - Helpers
private extension MapScreen {

    func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

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

// MARK: - Header / Search / Categories / Results
private extension MapScreen {

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

                Text(L("دليلك إلى كل ما هو حلال في مدينتك",
                       "Your guide to everything halal in your city"))
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

            TextField(L("ابحث عن مكان حلال…", "Search for a halal place…"),
                      text: $searchText)
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

    var topCategoryBar: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(L("التصنيفات", "Categories"))
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {

                    ForEach(topCategories) { category in
                        Button {
                            viewModel.searchNearby(category: category)
                            pushCategory = category
                        } label: {
                            HStack(spacing: 6) {
                                Text(category.emoji)
                                Text(localizedCategoryName(category))
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }

                    Button { showMoreCategories = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "ellipsis.circle.fill")
                            Text(L("المزيد", "More"))
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
        }
    }

    var resultsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L("نتائج البحث", "Search results"))
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                ForEach(viewModel.filteredPlaces) { place in
                    Button { selectedPlace = place } label: {
                        PlaceRowView(place: place)
                    }
                    Divider().padding(.leading, 16)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - HOME ADS (Sponsored + Trending)
private extension MapScreen {

    // ✅ FirebaseAd -> Ad (حتى لا نكسر UI)
    private var activeAds: [Ad] {
        adsStore.activeAds
            .sorted { $0.createdAt > $1.createdAt }
            .map { $0.toLocalAdFallback() }
    }

    private var sponsoredAds: [Ad] {
        activeAds.filter { $0.tier == .prime || $0.tier == .standard }
    }

    private var trendingAds: [Ad] {
        activeAds.filter { $0.tier == .free }
    }

    var homeAdsSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            sectionTitle(L("Sponsored", "Sponsored"))
            if sponsoredAds.isEmpty {
                emptyBox(text: L("لا يوجد Sponsored بعد.", "No Sponsored ads yet."))
            } else {
                VStack(spacing: 12) {
                    ForEach(sponsoredAds) { ad in
                        adButtonCard(ad)
                    }
                }
            }

            sectionTitle(L("Trending", "Trending"))
            if trendingAds.isEmpty {
                emptyBox(text: L("لا يوجد Trending بعد.", "No Trending ads yet."))
            } else {
                VStack(spacing: 12) {
                    ForEach(trendingAds) { ad in
                        adButtonCard(ad)
                    }
                }
            }

            if activeAds.isEmpty {
                emptyBox(text: L(
                    "لا يوجد إعلانات بعد. افتح تبويب الإعلانات وأضف إعلان (1–3 صور) وسيظهر هنا.",
                    "No ads yet. Open Ads tab and add an ad (1–3 photos) and it will appear here."
                ))
            }
        }
        .padding(.top, 4)
    }

    func sectionTitle(_ title: String) -> some View {
        HStack { Text(title).font(.headline); Spacer() }
    }

    func emptyBox(text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemGray6)))
    }

    func adButtonCard(_ ad: Ad) -> some View {
        Button {
            if let pid = ad.placeId,
               let place = viewModel.places.first(where: { $0.id == pid }) {
                selectedPlace = place
            }
        } label: {
            adCard(ad: ad)
        }
        .buttonStyle(.plain)
    }

    func adCard(ad: Ad) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // ✅ يدعم Local filenames أو URL
            adImagesCarousel(paths: ad.imagePaths)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {

                    if let pid = ad.placeId,
                       let place = viewModel.places.first(where: { $0.id == pid }) {

                        Text(place.name)
                            .font(.subheadline.bold())
                            .lineLimit(1)

                        Text("\(place.category.emoji) \(localizedCategoryName(place.category))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                    } else {
                        Text(L("إعلان", "Ad"))
                            .font(.subheadline.bold())

                        Text(ad.placeId ?? "—")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Text(badgeText(for: ad.tier))
                    .font(.caption2.bold())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.systemGray5), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    func badgeText(for tier: Ad.Tier) -> String {
        switch tier {
        case .prime:    return L("Prime", "Prime")
        case .standard: return L("مدفوع", "Paid")
        case .free:     return L("مجاني", "Free")
        }
    }

    // ✅ Local filename OR URL
    func adImagesCarousel(paths: [String]) -> some View {
        Group {
            if paths.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
                    VStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(L("صورة إعلان", "Ad image"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else if paths.count == 1 {
                adImageView(from: paths[0])
            } else {
                TabView {
                    ForEach(Array(paths.prefix(3)), id: \.self) { p in
                        adImageView(from: p)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
    }

    @ViewBuilder
    func adImageView(from path: String) -> some View {
        if let url = URL(string: path), url.scheme?.hasPrefix("http") == true {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill().clipped()
                case .failure:
                    RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
                case .empty:
                    RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
                @unknown default:
                    RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
                }
            }
        } else if let img = loadLocalImage(named: path) {
            Image(uiImage: img).resizable().scaledToFill().clipped()
        } else {
            RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
        }
    }

    func loadLocalImage(named filename: String) -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
}

// MARK: - FirebaseAd -> Ad Adapter (Fallback-safe)
private extension FirebaseAd {
    func toLocalAdFallback() -> Ad {

        let tierEnum: Ad.Tier = {
            switch tier.lowercased() {
            case "prime": return .prime
            case "standard": return .standard
            default: return .free
            }
        }()

        let statusEnum: Ad.Status = .active
        // ✅ fallback values (حتى لو enums عندك مختلفة)
        let bt: Ad.BusinessType = .restaurant
        let tp: Ad.CopyTemplate = .simple

        return Ad(
            tier: tierEnum,
            status: statusEnum,
            placeId: placeId,
            imagePaths: imageURLs,   // URLs أو filenames
            businessName: businessName,
            ownerName: ownerName,
            phone: phone,
            addressLine: addressLine,
            city: city,
            state: state,
            businessType: bt,
            template: tp,
            createdAt: createdAt,
            expiresAt: expiresAt ?? Date().addingTimeInterval(14 * 24 * 60 * 60),
            freeCooldownKey: phone
        )
    }
}

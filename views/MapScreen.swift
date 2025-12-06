import SwiftUI
import MapKit

struct MapScreen: View {
    // MARK: - State
    @StateObject private var viewModel = MapScreenViewModel()

    @State private var selectedCategory: PlaceCategory? = nil
    @State private var searchText: String = ""
    @State private var showResults: Bool = true
    @State private var selectedPlace: Place? = nil
    @State private var showJobAds: Bool = false   // زر إعـلان عمل مستقل

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                header
                searchBar
                categoryFilters

                // 🔺 الإعلانات العلوية
                topAdsSection
                    .padding(.horizontal)

                // 🗺 الخريطة في الوسط
                mapView

                // 🔻 الإعلانات السفلية
                bottomAdsSection
                    .padding(.horizontal)

                if showResults {
                    resultsList
                }
            }
            .navigationDestination(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
            .sheet(isPresented: $showJobAds) {
                JobAdsScreen()
            }
        }
    }
}

// MARK: - Subviews: Header / Search / Categories / Map / List
private extension MapScreen {

    var header: some View {
        HStack {
            Text("Halal Map")
                .font(.title2.bold())
            Spacer()
        }
        .padding(.horizontal)
    }

    var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search for a halal place…", text: $searchText)
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

    var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PlaceCategory.allCases) { category in
                    Button {
                        if selectedCategory == category {
                            selectedCategory = nil
                            viewModel.searchNearby(category: nil)
                        } else {
                            selectedCategory = category
                            viewModel.searchNearby(category: category)
                        }
                        viewModel.filterBySearch(text: searchText)
                    } label: {
                        Text(category.displayName)
                            .font(.subheadline)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                (selectedCategory == category)
                                ? category.mapColor.opacity(0.25)
                                : Color(.systemGray6)
                            )
                            .foregroundColor(
                                (selectedCategory == category)
                                ? .primary
                                : .secondary
                            )
                            .cornerRadius(10)
                    }
                }
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
        .frame(height: 230)   // الخريطة بالنص بارتفاع ثابت
        .cornerRadius(16)
        .padding(.horizontal)
    }

    var resultsList: some View {
        List(viewModel.filteredPlaces) { place in
            Button {
                selectedPlace = place
                viewModel.focus(on: place)
            } label: {
                PlaceRowView(place: place)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - ADS SECTIONS
private extension MapScreen {

    // 🔺 الإعلانات العلوية (فوق الخريطة)
    var topAdsSection: some View {
        VStack(spacing: 14) {

            // بانر برايم كبير (إبراهيم)
            bigPrimeBanner(
                titleEN: "Ibrahim Halal Restaurant",
                titleAR: "مطعم إبراهيم الحلال",
                subtitleEN: "Premium halal restaurant – top visibility in Halal Map Prime.",
                subtitleAR: "إعلان مميز يظهر في أعلى نتائج البحث في نيويورك ونيوجيرسي.",
                tagText: "PRIME • FEATURED",
                logoName: "ibrahim_logo"
            )

            // 3 بانرات Prime صغيرة
            HStack(spacing: 10) {
                smallPrimeBanner(
                    icon: "fork.knife",
                    title: "Halal Restaurants",
                    subtitle: "Top nearby picks"
                )
                smallPrimeBanner(
                    icon: "mappin.and.ellipse",
                    title: "Mosques / Masjid",
                    subtitle: "Prayer & Jumu’ah"
                )
                smallPrimeBanner(
                    icon: "cart.fill",
                    title: "Groceries",
                    subtitle: "Fresh halal products"
                )
            }

            // بانر المدارس
            bigSchoolsBanner(
                titleEN: "Islamic Schools & Programs",
                titleAR: "مدارس وبرامج إسلامية",
                subtitleEN: "Weekend schools, Qur’an & after-school programs.",
                subtitleAR: "مدارس نهاية الأسبوع، حفظ القرآن، وبرامج بعد المدارس."
            )
        }
    }

    // 🔻 الإعلانات السفلية (تحت الخريطة)
    var bottomAdsSection: some View {
        VStack(spacing: 14) {

            // 3 بانرات Standard
            HStack(spacing: 10) {
                smallNormalBanner(
                    icon: "truck.box.fill",
                    title: "Food Trucks",
                    subtitle: "Mobile halal kitchens"
                )
                smallNormalBanner(
                    icon: "bag.fill",
                    title: "Shops & Markets",
                    subtitle: "Retail & wholesale"
                )
                smallNormalBanner(
                    icon: "person.2.fill",
                    title: "Community Services",
                    subtitle: "Services for the Muslim community"
                )
            }

            // شريطين الوظائف
            VStack(spacing: 8) {
                jobStrip(
                    text: "🔍 ابحث عن عمل؟ / Looking for a job?",
                    background: .red
                )
                jobStrip(
                    text: "💼 يوجد عمل / Jobs available",
                    background: .blue
                )
            }

            // زر منفصل لإضافة إعلان عمل
            Button {
                showJobAds = true
            } label: {
                Text("أضف إعلان عمل / Post a job")
                    .font(.subheadline.bold())
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
        }
    }

    // ⬇️ نفس دوال البانرات اللي عندك (ما لمسنا ولا Firebase ولا Google)

    func bigPrimeBanner(
        titleEN: String,
        titleAR: String,
        subtitleEN: String,
        subtitleAR: String,
        tagText: String,
        logoName: String?
    ) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.35, blue: 0.20),
                    Color(red: 0.80, green: 0.05, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                .blendMode(.overlay)

            HStack(spacing: 14) {
                if let logoName = logoName, !logoName.isEmpty {
                    Image(logoName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 4)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.black.opacity(0.15))
                        Text("HMP")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }
                    .frame(width: 52, height: 52)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(titleEN)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(titleAR)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.95))

                    Text(subtitleEN)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)

                    Text(subtitleAR)
                        .font(.caption2)
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

            Text("Prime")
                .font(.caption2)
                .foregroundColor(.orange)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.yellow.opacity(0.22))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }

    func bigSchoolsBanner(
        titleEN: String,
        titleAR: String,
        subtitleEN: String,
        subtitleAR: String
    ) -> some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [Color.green.opacity(0.95), Color.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(titleEN)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(titleAR)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.95))

                    Text(subtitleEN)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)

                    Text(subtitleAR)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(12)
        }
        .frame(height: 95)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
    }

    func smallNormalBanner(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.bold())
            }

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text("Standard")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }

    func jobStrip(text: String, background: Color) -> some View {
        HStack {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(background.opacity(0.96))
        .cornerRadius(14)
        .shadow(color: background.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

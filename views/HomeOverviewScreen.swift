import SwiftUI

struct HomeOverviewScreen: View {

    @EnvironmentObject var lang: LanguageManager

    // ✅ callbacks لتغيير التبويب من Home
    let onOpenJobs: () -> Void
    let onOpenMap: () -> Void
    let onOpenFaith: () -> Void

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    enum HomeRoute: Hashable {
        case category(PlaceCategory)
    }

    @State private var path: [HomeRoute] = []

    // Sheets
    @State private var showAddPlace = false
    @State private var showPaidAdsInfo = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 16) {

                    jobsTeaserCard
                        .padding(.horizontal)

                    paidAdsBannerSection
                        .padding(.horizontal)

                    quickActionsRow
                        .padding(.horizontal)

                    // ✅ Categories Grid
                    HomeCategoriesGrid { category in
                        path.append(.category(category))
                    }
                    .environmentObject(lang)
                }
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(L("الرئيسية", "Home"))
            .navigationBarTitleDisplayMode(.inline)

            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .category(let category):
                    MapScreen(startingCategory: category, hideCategoryPicker: true)
                        .environmentObject(lang)
                        .navigationTitle(category.displayName(isArabic: lang.isArabic))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }

            .sheet(isPresented: $showAddPlace) {
                AddStoreScreen()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showPaidAdsInfo) {
                AdsHomeScreen()
                    .environmentObject(lang)
            }
        }
    }
}

// MARK: - Sections
private extension HomeOverviewScreen {

    var jobsTeaserCard: some View {
        Button {
            onOpenJobs()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.green.opacity(0.15))
                    Image(systemName: "briefcase.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L("وظائف قريبة منك اليوم", "Jobs near you today"))
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(L("افتح الوظائف وشوف الجديد. خليها عادة يومية ✅", "Open Jobs and check what’s new. Make it a daily habit ✅"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    var paidAdsBannerSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(L("إعلانات مدفوعة", "Paid Ads"))
                    .font(.headline)
                Spacer()
                Button {
                    showPaidAdsInfo = true
                } label: {
                    Text(L("المزيد", "More"))
                        .font(.subheadline.weight(.semibold))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(demoBannerAds) { ad in
                        bannerCard(ad)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    func bannerCard(_ ad: BannerAd) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: ad.imageSystemName)
                    .foregroundColor(.orange)
                Spacer()
                Text(L("مميز", "Featured"))
                    .font(.caption2.bold())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(ad.title)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(ad.subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(width: 240, height: 110)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    var quickActionsRow: some View {
        HStack(spacing: 10) {

            Button {
                showAddPlace = true
            } label: {
                quickButton(
                    icon: "plus.circle.fill",
                    title: L("أضف مكان", "Add Place")
                )
            }

            Button {
                onOpenMap()
            } label: {
                quickButton(
                    icon: "location.fill",
                    title: L("القريب مني", "Near me")
                )
            }

            Button {
                onOpenFaith()
            } label: {
                quickButton(
                    icon: "moon.stars.fill",
                    title: L("الإيمان", "Faith")
                )
            }
        }
    }

    func quickButton(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(.subheadline.bold())
            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 2)
    }
}

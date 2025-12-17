//
//  AdsHomeScreen.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//

import SwiftUI

struct AdsHomeScreen: View {

    @ObservedObject private var adsStore = AdsStore.shared

    // ✅ FirebaseAd -> Ad (حتى تظل AdCard شغالة بدون تغيير كبير)
    private var activeAds: [Ad] {
        adsStore.activeAds
            .sorted { $0.createdAt > $1.createdAt }
            .map { $0.toLocalAdForUI() }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    ForEach(activeAds) { ad in
                        AdCard(ad: ad)
                    }

                    if activeAds.isEmpty {
                        Text("No ads available")
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    }
                }
                .padding()
            }
            .navigationTitle("Ads")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                adsStore.startActiveListener()
            }
        }
    }
}

// MARK: - Ad Card (CLEAN)

private struct AdCard: View {

    let ad: Ad

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            AdImagesCarousel(paths: ad.imagePaths)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 4) {

                Text("Sponsored")
                    .font(.subheadline.bold())

                Text(badgeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        )
    }

    private var badgeText: String {
        switch ad.tier {
        case .prime:
            return "⭐ Prime Ad"
        case .standard:
            return "💼 Paid Ad"
        case .free:
            return "🆓 Free Ad"
        }
    }
}

// MARK: - Images Carousel (Local filename OR URL)

private struct AdImagesCarousel: View {

    let paths: [String]

    var body: some View {
        Group {
            if paths.isEmpty {
                Color(.systemGray5)
            } else if paths.count == 1 {
                imageView(from: paths[0])
            } else {
                TabView {
                    ForEach(paths.prefix(3), id: \.self) { p in
                        imageView(from: p)
                    }
                }
                .tabViewStyle(.page)
            }
        }
    }

    @ViewBuilder
    private func imageView(from path: String) -> some View {
        // ✅ URL from Firebase Storage
        if let url = URL(string: path), url.scheme?.hasPrefix("http") == true {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .clipped()
                case .failure:
                    Color(.systemGray5)
                case .empty:
                    Color(.systemGray5)
                @unknown default:
                    Color(.systemGray5)
                }
            }
        }
        // ✅ Local filename (old)
        else if let image = loadLocalImage(named: path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            Color(.systemGray5)
        }
    }

    private func loadLocalImage(named filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        return UIImage(contentsOfFile: url.path)
    }
}

// MARK: - FirebaseAd -> Ad adapter (for UI)

private extension FirebaseAd {
    func toLocalAdForUI() -> Ad {

        let tierEnum: Ad.Tier = {
            switch tier.lowercased() {
            case "prime": return .prime
            case "standard": return .standard
            default: return .free
            }
        }()

        // ✅ حسب أخطائك السابقة: ما عندك .inactive
        let statusEnum: Ad.Status = .active

        // ✅ fallback enums (إذا عندك حالات مختلفة ابعتلي enum وسأضبطها)
        let bt: Ad.BusinessType = .restaurant
        let tp: Ad.CopyTemplate = .simple

        return Ad(
            tier: tierEnum,
            status: statusEnum,
            placeId: placeId,
            imagePaths: imageURLs, // URLs (أو filenames القديمة)
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

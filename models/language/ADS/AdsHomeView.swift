//
//  AdsHomeView.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 12/16/25.
//  Updated by Zaid Nahleh on 12/18/25.
//

import SwiftUI

struct AdsHomeView: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var store = AdsStore.shared

    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showAddAd = false

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    headerButtons

                    if isLoading {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text(L("جاري التحميل…", "Loading…"))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 8)
                    }

                    if !isLoading, store.activeAds.isEmpty {
                        Text(L("لا يوجد إعلانات حالياً.", "No ads available right now."))
                            .foregroundColor(.secondary)
                            .padding(.top, 30)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(store.activeAds) { ad in
                            FirebaseAdCard(ad: ad, isArabic: lang.isArabic)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(L("الإعلانات", "Ads"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await start()
            }
            .onDisappear {
                // ✅ امنع تكرار listeners لما ترجع/تطلع من التبويب
                store.stopAllListeners()
            }
            .sheet(isPresented: $showAddAd) {
                // ✅ إذا عندك FreeAdFormView موجودة بالمشروع: رح تشتغل
                FreeAdFormView()
                    .environmentObject(lang)
            }
        }
    }

    private var headerButtons: some View {
        HStack(spacing: 10) {

            Button {
                showAddAd = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text(L("إضافة إعلان", "Add Ad"))
                }
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            NavigationLink {
                MyAdsView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text(L("إعلاناتي", "My Ads"))
                }
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // ✅ Start: ensure login then start listener
    private func start() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            _ = try await AuthManager.shared.ensureSignedIn()

            await MainActor.run {
                store.startActiveListener()
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = L(
                    "فشل تسجيل الدخول: \(error.localizedDescription)",
                    "Auth failed: \(error.localizedDescription)"
                )
            }
        }
    }
}

// MARK: - Firebase Ad Card

private struct FirebaseAdCard: View {

    let ad: FirebaseAd
    let isArabic: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            FirebaseAdImagesCarousel(urls: ad.imageURLs)
                .frame(height: 190)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text(ad.businessName.isEmpty ? (isArabic ? "إعلان" : "Ad") : ad.businessName)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    Text(statusBadge)
                        .font(.caption2.bold())
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                        .foregroundColor(.secondary)
                }

                Text("\(ad.city), \(ad.state)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(tierBadge)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    private var tierBadge: String {
        switch ad.tier.lowercased() {
        case "prime":
            return isArabic ? "⭐ برايم" : "⭐ Prime"
        case "standard":
            return isArabic ? "💼 مدفوع" : "💼 Paid"
        default:
            return isArabic ? "🆓 مجاني" : "🆓 Free"
        }
    }

    private var statusBadge: String {
        // ✅ أهم نقطة: Expired ما يخلي الشاشة فاضية — يعرضها كبادج
        if ad.isExpired { return isArabic ? "منتهي" : "Expired" }
        return ad.isActive ? (isArabic ? "فعّال" : "Active") : (isArabic ? "غير فعّال" : "Inactive")
    }
}

// MARK: - Images Carousel (Firebase URLs)

private struct FirebaseAdImagesCarousel: View {

    let urls: [String]

    var body: some View {
        Group {
            if urls.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            } else if urls.count == 1, let u = URL(string: urls[0]) {
                FirebaseAdImage(url: u)
            } else {
                TabView {
                    ForEach(Array(urls.prefix(3)), id: \.self) { s in
                        if let u = URL(string: s) {
                            FirebaseAdImage(url: u)
                        } else {
                            RoundedRectangle(cornerRadius: 18).fill(Color(.systemGray5))
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
    }
}

private struct FirebaseAdImage: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack { Color(.systemGray5); ProgressView() }
            case .success(let image):
                image.resizable().scaledToFill().clipped()
            case .failure:
                ZStack { Color(.systemGray5); Image(systemName: "xmark.octagon").foregroundColor(.secondary) }
            @unknown default:
                Color(.systemGray5)
            }
        }
    }
}

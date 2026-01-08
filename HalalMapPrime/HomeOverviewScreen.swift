//
//  HomeOverviewScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2026-01-05.
//  Copyright © 2026 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import Combine
import UIKit

struct HomeOverviewScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var router: AppRouter

    private let db = Firestore.firestore()
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    // ✅ Local Ads
    @StateObject private var adsStore = AdsStore()

    // Jobs preview (from Firebase jobAds)
    @State private var previewJobs: [JobAd] = []
    @State private var jobsLoading: Bool = false
    @State private var tickerIndex: Int = 0

    // Distance (UI for now)
    @State private var radiusMiles: Int = 5
    @State private var showDistancePicker: Bool = false

    // Job alerts sheet
    @State private var showJobAlerts: Bool = false

    // Map sheet (category-based)
    @State private var showMapSheet: Bool = false
    @State private var mapStartingCategory: PlaceCategory? = nil

    // ✅ Ad Preview
    @State private var selectedAd: HMPAd? = nil
    @State private var showAdPreview: Bool = false

    private let tickerTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            IslamicPatternBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {

                    // 1) Categories
                    HomeCategoriesGrid { cat in openMap(cat) }

                    // 2) Jobs header
                    jobsHeaderRow

                    // 3) Job ticker
                    jobsTicker

                    // 3.5) Events ticker
                    HomeEventsTickerView()
                        .environmentObject(lang)
                        .environmentObject(router)
                        .padding(.horizontal, 16)
                        .padding(.top, 2)

                    // ✅ Ads on Home (distribution)
                    homeAdsHeaderRow
                    featuredSliderSection
                    monthlySpotlightSection
                    weeklyDealsSection
                }
                .padding(.top, 8)
                .padding(.bottom, 22)
            }
        }
        .onAppear {
            adsStore.load()
            fetchJobsPreview()
        }
        .onReceive(tickerTimer) { _ in
            guard !previewJobs.isEmpty else { return }
            tickerIndex = (tickerIndex + 1) % max(previewJobs.count, 1)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            adsStore.load()
        }
        .sheet(isPresented: $showDistancePicker) { distanceSheet }
        .sheet(isPresented: $showJobAlerts) { JobAlertsSheet().environmentObject(lang) }
        .sheet(isPresented: $showMapSheet) {
            MapScreen(startingCategory: mapStartingCategory, hideCategoryPicker: false)
                .environmentObject(lang)
                .environmentObject(router)
        }
        .sheet(isPresented: $showAdPreview) {
            if let ad = selectedAd {
                NavigationStack { AdPreviewScreen(langIsArabic: lang.isArabic, ad: ad) }
            }
        }
    }

    // MARK: - Home Ads Header Row

    private var homeAdsHeaderRow: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "megaphone.fill")
                    .foregroundColor(.primary)
                Text(L("إعلانات قريبة منك", "Ads near you"))
                    .font(.headline)
            }

            Spacer()

            Button {
                adsStore.load()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)

            Button {
                router.selectedTab = 2
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Text(L("المزيد", "More"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    // MARK: - Featured Slider (Prime + FreeOnce)

    private var featuredSliderSection: some View {
        let featured = adsStore.activePublicAds.filter { $0.plan == .prime || $0.plan == .freeOnce }

        return Group {
            if featured.isEmpty {
                // silent
                EmptyView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(featured) { ad in
                            FeaturedAdSliderCard(langIsArabic: lang.isArabic, ad: ad) {
                                selectedAd = ad
                                showAdPreview = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                            .frame(width: 320)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                }
            }
        }
    }

    // MARK: - Monthly Spotlight

    private var monthlySpotlightSection: some View {
        let monthly = adsStore.activePublicAds.filter { $0.plan == .monthly }

        return Group {
            if monthly.isEmpty {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 10) {

                    Text(L("إعلانات شهرية", "Monthly Spotlight"))
                        .font(.headline)
                        .padding(.horizontal, 16)

                    VStack(spacing: 10) {
                        ForEach(monthly.prefix(4)) { ad in
                            Button {
                                selectedAd = ad
                                showAdPreview = true
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                MonthlySpotlightCard(langIsArabic: lang.isArabic, ad: ad)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Weekly Deals

    private var weeklyDealsSection: some View {
        let weekly = adsStore.activePublicAds.filter { $0.plan == .weekly }

        return Group {
            if weekly.isEmpty {
                // if everything empty, show one empty state
                if weekly.isEmpty {
                    Text(L("لا توجد إعلانات حالياً.", "No ads right now."))
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 16)
                } else {
                    EmptyView()
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {

                    Text(L("إعلانات أسبوعية", "Weekly Deals"))
                        .font(.headline)
                        .padding(.horizontal, 16)

                    VStack(spacing: 10) {
                        ForEach(weekly.prefix(8)) { ad in
                            Button {
                                selectedAd = ad
                                showAdPreview = true
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                CompactAdCard(langIsArabic: lang.isArabic, ad: ad)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Jobs Header

    private var jobsHeaderRow: some View {
        HStack(spacing: 10) {

            HStack(spacing: 8) {
                Image(systemName: "briefcase.fill")
                    .foregroundColor(.primary)
                Text(L("وظائف قريبة منك", "Jobs near you"))
                    .font(.headline)
            }

            Spacer()

            Button {
                showJobAlerts = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.orange.opacity(0.95))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button { showDistancePicker = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text("\(radiusMiles) mi")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.95))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                router.selectedTab = 1
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    // MARK: - Jobs Ticker

    private var jobsTicker: some View {
        VStack(alignment: .leading, spacing: 10) {

            if jobsLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text(L("جاري تحميل الوظائف…", "Loading jobs…"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 16)

            } else if previewJobs.isEmpty {
                Text(L("لا توجد وظائف حالياً.", "No jobs right now."))
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)

            } else {
                let ad = previewJobs[tickerIndex % max(previewJobs.count, 1)]

                Button { router.selectedTab = 1 } label: {
                    HStack(spacing: 12) {

                        ZStack {
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 42, height: 42)
                                .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)

                            Image(systemName: ad.type == .hiring ? "person.badge.plus" : "magnifyingglass")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(ad.type == .hiring ? Color.blue : Color.green)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(headlineForJob(ad))
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)

                            Text(ad.city.isEmpty ? L("قريب منك", "Near you") : ad.city)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Text(L("جديد", "New"))
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.75))
                            .clipShape(Capsule())

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
        }
    }

    private func headlineForJob(_ ad: JobAd) -> String {
        let cat = ad.category.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cat.isEmpty {
            return ad.type == .hiring
            ? L("مطلوب موظف • \(cat)", "Hiring • \(cat)")
            : L("أبحث عن عمل • \(cat)", "Seeking • \(cat)")
        } else {
            return ad.type == .hiring ? L("مطلوب موظف", "Hiring") : L("أبحث عن عمل", "Seeking")
        }
    }

    // MARK: - Map open

    private func openMap(_ category: PlaceCategory) {
        mapStartingCategory = category
        showMapSheet = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Distance sheet

    private var distanceSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text(L("حدد نطاق المسافة", "Choose distance range"))
                    .font(.title3.weight(.semibold))
                    .padding(.top, 10)

                VStack(spacing: 10) {
                    ForEach([1, 3, 5, 10, 15, 25], id: \.self) { miles in
                        Button {
                            radiusMiles = miles
                            showDistancePicker = false
                        } label: {
                            HStack {
                                Text("\(miles) mi").font(.headline)
                                Spacer()
                                if miles == radiusMiles { Image(systemName: "checkmark.circle.fill") }
                            }
                            .padding()
                            .background(Color(.systemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle(L("المسافة", "Distance"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("تم", "Done")) { showDistancePicker = false }
                }
            }
        }
    }

    // MARK: - Firestore fetch (Job Ads)

    private func fetchJobsPreview() {
        jobsLoading = true

        db.collection("jobAds")
            .order(by: "createdAt", descending: true)
            .limit(to: 30)
            .getDocuments { snap, error in
                DispatchQueue.main.async {
                    self.jobsLoading = false

                    guard error == nil, let docs = snap?.documents else {
                        self.previewJobs = []
                        return
                    }

                    let all = docs.compactMap { JobAd(from: $0) }

                    self.previewJobs = all.sorted {
                        ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
                    }

                    self.tickerIndex = 0
                }
            }
    }
}

// MARK: - Featured Slider Card (Prime + FreeOnce) with Images

private struct FeaturedAdSliderCard: View {
    let langIsArabic: Bool
    let ad: HMPAd
    let onTap: () -> Void

    private func L(_ ar: String, _ en: String) -> String { langIsArabic ? ar : en }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {

                // Images
                if !ad.uiImages().isEmpty {
                    TabView {
                        ForEach(Array(ad.uiImages().enumerated()), id: \.offset) { _, img in
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 170)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    .frame(height: 170)
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 120)

                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.yellow)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(ad.plan == .prime ? L("إعلان مميز", "Featured Prime") : L("إعلان مجاني مميز", "Featured Free"))
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.secondary)

                                Text(ad.businessName)
                                    .font(.headline.weight(.bold))
                                    .lineLimit(1)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ad.businessName)
                            .font(.headline.weight(.bold))
                            .lineLimit(1)
                        Text(ad.headline)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(ad.plan == .prime ? L("PRIME", "PRIME") : L("هدية", "GIFT"))
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.yellow.opacity(0.95))
                        .clipShape(Capsule())
                }

                Text(ad.adText)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text(ad.remainingText(langIsArabic: langIsArabic))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.yellow.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.09), radius: 14, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Monthly Spotlight Card (bigger)

private struct MonthlySpotlightCard: View {
    let langIsArabic: Bool
    let ad: HMPAd

    private func L(_ ar: String, _ en: String) -> String { langIsArabic ? ar : en }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ad.businessName)
                        .font(.headline.weight(.bold))
                        .lineLimit(1)
                    Text(ad.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(L("شهري", "MONTHLY"))
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.9))
                    .clipShape(Capsule())
            }

            if let first = ad.uiImages().first {
                Image(uiImage: first)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Text(ad.adText)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)

            HStack {
                Text(ad.remainingText(langIsArabic: langIsArabic))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Weekly Compact Card

private struct CompactAdCard: View {
    let langIsArabic: Bool
    let ad: HMPAd

    var body: some View {
        HStack(spacing: 12) {

            if let img = ad.uiImages().first {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 64, height: 64)
                    .overlay(Image(systemName: "photo").foregroundColor(.secondary))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(ad.businessName)
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                Text(ad.headline)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(ad.adText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 6)
    }
}


// MARK: - Islamic Pattern Background (subtle)

private struct IslamicPatternBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground),
                    Color(.systemGroupedBackground).opacity(0.94),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Canvas { context, size in
                let step: CGFloat = 60
                let dotSize: CGFloat = 2.0

                for y in stride(from: 0, through: size.height + step, by: step) {
                    for x in stride(from: 0, through: size.width + step, by: step) {
                        let center = CGPoint(x: x, y: y)

                        let dot = Path(ellipseIn: CGRect(x: center.x - dotSize/2, y: center.y - dotSize/2, width: dotSize, height: dotSize))
                        context.fill(dot, with: .color(Color.black.opacity(0.045)))

                        var star = Path()
                        let r1: CGFloat = 11
                        let r2: CGFloat = 5
                        let points = 16
                        for i in 0..<points {
                            let angle = (CGFloat(i) * (2 * .pi / CGFloat(points))) - .pi/2
                            let r = (i % 2 == 0) ? r1 : r2
                            let p = CGPoint(x: center.x + cos(angle)*r, y: center.y + sin(angle)*r)
                            if i == 0 { star.move(to: p) } else { star.addLine(to: p) }
                        }
                        star.closeSubpath()
                        context.stroke(star, with: .color(Color.black.opacity(0.03)), lineWidth: 1)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

//
//  HomeOverviewScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-27.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct HomeOverviewScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var router: AppRouter

    private let db = Firestore.firestore()

    // Jobs preview (OLD JobAd model)
    @State private var previewJobs: [JobAd] = []
    @State private var jobsLoading: Bool = false
    @State private var tickerIndex: Int = 0

    // Distance UI (visual فقط الآن)
    @State private var radiusMiles: Int = 5
    @State private var showDistancePicker: Bool = false

    // ✅ NEW: فتح الخريطة من الصفحة الرئيسية
    @State private var showMapSheet: Bool = false
    @State private var mapCategoryToOpen: PlaceCategory? = nil

    private let tickerTimer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {

                // Categories row (4 important) + More
                categoriesRow

                // Jobs header row + buttons
                jobsHeaderRow

                // Clean ticker (one job at a time)
                tickerView

                // Featured paid ads (placeholder slider)
                featuredPaidAdsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 22)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { fetchJobsPreview() }
        .onReceive(tickerTimer) { _ in
            guard !previewJobs.isEmpty else { return }
            tickerIndex = (tickerIndex + 1) % max(previewJobs.count, 1)
        }
        .sheet(isPresented: $showDistancePicker) {
            distanceSheet
        }
        // ✅ NEW: Sheet للخريطة مباشرة مع category
        .sheet(isPresented: $showMapSheet) {
            MapScreen(startingCategory: mapCategoryToOpen, hideCategoryPicker: false)
                .environmentObject(lang)
                .environmentObject(router)
        }
    }

    // MARK: - Categories

    private var categoriesRow: some View {
        HStack(spacing: 12) {

            categoryChip(.restaurant)
            categoryChip(.grocery)
            categoryChip(.market)
            categoryChip(.shop)

            Spacer()

            Menu {
                Button { openCategory(.mosque) } label: { Label(L("مساجد", "Mosques"), systemImage: "moon.stars.fill") }
                Button { openCategory(.school) } label: { Label(L("مدارس", "Schools"), systemImage: "graduationcap.fill") }
                Button { openCategory(.service) } label: { Label(L("خدمات", "Services"), systemImage: "wrench.and.screwdriver.fill") }
                Button { openCategory(.foodTruck) } label: { Label(L("فود ترك", "Food Trucks"), systemImage: "truck.box.fill") }
                Button { openCategory(.center) } label: { Label(L("مراكز", "Centers"), systemImage: "building.2.fill") }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "ellipsis.circle.fill")
                    Text(L("المزيد", "More"))
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            }
        }
    }

    private func categoryChip(_ category: PlaceCategory) -> some View {
        Button { openCategory(category) } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)

                    Text(category.emoji)
                        .font(.system(size: 18))
                }

                Text(shortName(category))
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 60)
        }
        .buttonStyle(.plain)
    }

    private func shortName(_ category: PlaceCategory) -> String {
        switch category {
        case .restaurant: return L("مطاعم", "Food")
        case .grocery:    return L("بقالة", "Grocery")
        case .market:     return L("ماركت", "Market")
        case .shop:       return L("متاجر", "Shops")
        case .mosque:     return L("مساجد", "Mosques")
        case .school:     return L("مدارس", "Schools")
        case .service:    return L("خدمات", "Service")
        case .foodTruck:  return L("فودترك", "Truck")
        case .center:     return L("مراكز", "Centers")
        }
    }

    /// ✅ FIX: بدل ما يعمل router.selectedTab = 0 (يرجع لنفس الصفحة)
    /// الآن يفتح الخريطة فوراً (Sheet) مع التصنيف
    private func openCategory(_ category: PlaceCategory) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        mapCategoryToOpen = category
        showMapSheet = true
    }

    // MARK: - Jobs Header

    private var jobsHeaderRow: some View {
        HStack(spacing: 10) {

            Text(L("وظائف قريبة", "Jobs near you"))
                .font(.headline)

            Spacer()

            // 🟡 Distance button (visual)
            Button { showDistancePicker = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text("\(radiusMiles) mi")
                }
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.95))
                .foregroundColor(.black)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // 🔔 notifications placeholder
            Button {
                // TODO later
            } label: {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.orange.opacity(0.95))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            // 🔵 Blue circle button -> Jobs tab
            Button {
                router.selectedTab = 1
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue.opacity(0.95))
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.25), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 6)
    }

    // MARK: - Ticker (OLD model)

    private var tickerView: some View {
        VStack(alignment: .leading, spacing: 10) {

            if jobsLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text(L("جاري تحميل الوظائف…", "Loading jobs…"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else if previewJobs.isEmpty {
                Text(L("لا توجد وظائف حالياً.", "No jobs right now."))
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                let ad = previewJobs[tickerIndex % max(previewJobs.count, 1)]

                Button {
                    router.selectedTab = 1
                } label: {
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
                            Text(headlineForOldAd(ad))
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)

                            Text(ad.city.isEmpty ? L("قريب منك", "Near you") : ad.city)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func headlineForOldAd(_ ad: JobAd) -> String {
        let cat = ad.category.trimmingCharacters(in: .whitespacesAndNewlines)
        let text = ad.text.trimmingCharacters(in: .whitespacesAndNewlines)

        let firstPart: String = text
            .split(separator: " ")
            .prefix(3)
            .joined(separator: " ")

        if !cat.isEmpty {
            return "\(firstPart) • \(cat)"
        } else {
            return firstPart.isEmpty ? (ad.type == .hiring ? L("مطلوب موظف", "Hiring") : L("أبحث عن عمل", "Looking for job")) : firstPart
        }
    }

    // MARK: - Featured paid ads (placeholder)

    private var featuredPaidAdsSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(L("إعلانات مميزة", "Featured"))
                .font(.headline)
                .padding(.top, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    featuredCard(title: "Halal Grill", subtitle: L("مميز • عرض محدود", "Sponsored • Limited offer"))
                    featuredCard(title: "Quality One HVAC", subtitle: L("مميز • 24/7", "Sponsored • 24/7 Service"))
                    featuredCard(title: "Grocery Market", subtitle: L("مميز • عروض", "Sponsored • Deals"))
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func featuredCard(title: String, subtitle: String) -> some View {
        Button { } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title).font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "crown.fill").foregroundColor(.yellow)
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(14)
            .frame(width: 220)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Distance sheet

    private var distanceSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text(L("حدد نطاق المسافة", "Choose distance range"))
                    .font(.title3.weight(.semibold))
                    .padding(.top, 10)

                VStack(spacing: 12) {
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

    // MARK: - Firestore fetch (OLD model)

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

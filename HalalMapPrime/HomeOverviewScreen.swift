//
//  HomeOverviewScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-31.
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
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

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

    // Jobs ticker changes every 60 seconds (keep as is)
    private let tickerTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {

                // 1) Categories (visual)
                HomeCategoriesGrid { cat in
                    openMap(cat)
                }

                // 2) Core: Jobs (header row)
                jobsHeaderRow

                // 3) Core: One job ticker (changes every minute)
                jobsTicker

                // ✅ 3.5) NEW: Events ticker (PAID ONLY) – opens Community
                HomeEventsTickerView()
                    .environmentObject(lang)
                    .environmentObject(router)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)

                // 4) Paid Ads (placeholder UI for now)
                paidAdsSection
            }
            .padding(.top, 8)
            .padding(.bottom, 22)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { fetchJobsPreview() }
        .onReceive(tickerTimer) { _ in
            guard !previewJobs.isEmpty else { return }
            tickerIndex = (tickerIndex + 1) % max(previewJobs.count, 1)
        }
        .sheet(isPresented: $showDistancePicker) { distanceSheet }
        .sheet(isPresented: $showJobAlerts) {
            JobAlertsSheet()
                .environmentObject(lang)
        }
        .sheet(isPresented: $showMapSheet) {
            MapScreen(startingCategory: mapStartingCategory, hideCategoryPicker: false)
                .environmentObject(lang)
                .environmentObject(router)
        }
    }

    // MARK: - Jobs Header (bell + distance + see all)

    private var jobsHeaderRow: some View {
        HStack(spacing: 10) {

            HStack(spacing: 8) {
                Image(systemName: "briefcase.fill")
                    .foregroundColor(.primary)
                Text(L("وظائف قريبة منك", "Jobs near you"))
                    .font(.headline)
            }

            Spacer()

            // 🔔 Alerts
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

            // 📍 Distance (visual now)
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

            // ➜ Go to Jobs tab
            Button {
                router.selectedTab = 1
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L("عرض كل الوظائف", "See all jobs"))
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    // MARK: - Jobs Ticker (one card)

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
                            Text(headlineForAd(ad))
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

    private func headlineForAd(_ ad: JobAd) -> String {
        // very short, visual, no long text
        let cat = ad.category.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cat.isEmpty {
            return ad.type == .hiring
            ? L("مطلوب موظف • \(cat)", "Hiring • \(cat)")
            : L("أبحث عن عمل • \(cat)", "Seeking • \(cat)")
        } else {
            return ad.type == .hiring ? L("مطلوب موظف", "Hiring") : L("أبحث عن عمل", "Seeking")
        }
    }

    // MARK: - Paid Ads (placeholder)

    private var paidAdsSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(L("إعلانات مميزة", "Sponsored"))
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)

            VStack(spacing: 12) {
                sponsoredCard(title: "Halal Grill", subtitle: L("مميز • قريب منك", "Sponsored • Near you"))
                sponsoredCard(title: "Grocery Market", subtitle: L("مميز • عروض اليوم", "Sponsored • Today deals"))
                sponsoredCard(title: "Quality One HVAC", subtitle: L("مميز • 24/7", "Sponsored • 24/7"))
            }
            .padding(.horizontal, 16)
        }
    }

    private func sponsoredCard(title: String, subtitle: String) -> some View {
        Button { } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.systemBackground))
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)

                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)

                    Text(subtitle)
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
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Map open (category-based)

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
                            // لاحقاً: نربطها بفلترة حقيقية حسب lastLocation
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

    // MARK: - Firestore fetch (stable with your JobAd model)

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

                    // لاحقاً: فلترة حسب radiusMiles و lastLocation
                    self.previewJobs = all.sorted {
                        ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
                    }

                    self.tickerIndex = 0
                }
            }
    }
}

//
//  CommunityHubScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct CommunityHubScreen: View {

    @EnvironmentObject var lang: LanguageManager

    // Sheets
    @State private var showJobsBoard: Bool = false
    @State private var showPostJob: Bool = false
    @State private var showEventsBoard: Bool = false
    @State private var showNoticeBoard: Bool = false
    @State private var showAddPlace: Bool = false

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    headerSection
                        .padding(.horizontal)

                    // 🔥 GOLD: Jobs first
                    jobsHeroSection
                        .padding(.horizontal)

                    // Community Updates (secondary)
                    updatesSection
                        .padding(.horizontal)

                    addPlaceSection
                        .padding(.horizontal)

                    Spacer(minLength: 16)
                }
                .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(L("وظائف المجتمع", "Community Jobs"))
            .navigationBarTitleDisplayMode(.inline)

            // Sheets
            .sheet(isPresented: $showJobsBoard) {
                JobAdsBoardView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showPostJob) {
                JobAdsScreen()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showEventsBoard) {
                EventAdsBoardView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showNoticeBoard) {
                NoticeBoardView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showAddPlace) {
                AddStoreScreen()
                    .environmentObject(lang)
            }
        }
    }
}

// MARK: - Sections

private extension CommunityHubScreen {

    var headerSection: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.02, green: 0.35, blue: 0.28),
                                Color(red: 0.00, green: 0.60, blue: 0.52)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "briefcase.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(L("وظائف وفرص قريبة منك", "Jobs & opportunities near you"))
                    .font(.headline)

                Text(
                    L(
                        "هنا الشغل المتاح اليوم. تصفح الوظائف أو انشر إعلان توظيف بسرعة.",
                        "See available jobs today. Browse jobs or post a hiring ad fast."
                    )
                )
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    // 🔥 Jobs section (The gold)
    var jobsHeroSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("الوظائف (الأهم)", "Jobs (Most important)"))
                .font(.subheadline.bold())

            Text(
                L(
                    "اضغط زر واحد للتصفح، وزر واحد للنشر.",
                    "One tap to browse, one tap to post."
                )
            )
            .font(.caption)
            .foregroundColor(.secondary)

            HStack(spacing: 10) {

                Button {
                    showJobsBoard = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text(L("عرض الوظائف", "Browse jobs"))
                            .font(.subheadline.bold())
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(Color.green.opacity(0.95))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)

                Button {
                    showPostJob = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(L("انشر وظيفة", "Post a job"))
                            .font(.subheadline.bold())
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // Secondary
    var updatesSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("تحديثات المجتمع", "Community updates"))
                .font(.subheadline.bold())

            VStack(spacing: 10) {

                FreeAdCard(
                    title: L("إعلانات الفعاليات", "Events"),
                    subtitle: L("إفطارات، دروس، لقاءات ونشاطات", "Iftars, lectures, meetups & activities"),
                    icon: "calendar.badge.plus",
                    accent: .blue
                ) { showEventsBoard = true }

                FreeAdCard(
                    title: L("لوحة الإعلانات العامة", "Notice board"),
                    subtitle: L("تنبيهات، مفقودات، إعلانات عامة", "Alerts, lost & found, general notices"),
                    icon: "text.bubble.fill",
                    accent: .teal
                ) { showNoticeBoard = true }
            }
        }
    }

    var addPlaceSection: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(L("شارك مكانك مع المجتمع", "Share your place"))
                .font(.subheadline.bold())

            Text(
                L(
                    "أضف مسجدًا، مطعمًا حلالاً، محل بقالة أو أي نشاط يخدم المجتمع.",
                    "Add a masjid, halal restaurant, grocery, or any place serving the community."
                )
            )
            .font(.caption)
            .foregroundColor(.secondary)

            Button { showAddPlace = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color(red: 0.00, green: 0.55, blue: 0.50)))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("إضافة مسجد / مطعم / محل حلال", "Add masjid / restaurant / halal store"))
                            .font(.subheadline.bold())

                        Text(L("ساعد غيرك يجد الأماكن بسهولة.", "Help others find halal places easily."))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Card

private struct FreeAdCard: View {

    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accent.opacity(0.14))
                    Image(systemName: icon)
                        .font(.headline)
                        .foregroundColor(accent)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}


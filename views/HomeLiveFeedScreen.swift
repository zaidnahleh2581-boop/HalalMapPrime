//
//  HomeLiveFeedScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct HomeLiveFeedScreen: View {

    @EnvironmentObject var lang: LanguageManager

    /// نوع المحتوى المعروض الآن
    enum LiveItemType {
        case job
        case community
        case faith
    }

    /// مؤقتاً: نغيّر النوع يدوياً (لاحقاً من ViewModel)
    @State private var currentType: LiveItemType = .job

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                header

                Spacer()

                liveCard

                Spacer()

            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 4) {
            Text(L("الآن", "Now"))
                .font(.largeTitle.bold())

            Text(L("شيء مهم يحدث حولك", "Something important happening near you"))
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Live Card
    @ViewBuilder
    private var liveCard: some View {
        switch currentType {
        case .job:
            liveJobCard
        case .community:
            liveCommunityCard
        case .faith:
            liveFaithCard
        }
    }

    // MARK: - Job Card
    private var liveJobCard: some View {
        LiveCard(
            icon: "briefcase.fill",
            title: L("وظيفة متاحة الآن", "Job available now"),
            message: L(
                "مطعم حلال في Brooklyn يحتاج كاشير الآن.",
                "A halal restaurant in Brooklyn needs a cashier now."
            ),
            primaryAction: L("اتصل الآن", "Call now"),
            secondaryAction: L("عرض التفاصيل", "View details"),
            accent: .green
        )
    }

    // MARK: - Community Card
    private var liveCommunityCard: some View {
        LiveCard(
            icon: "person.3.fill",
            title: L("تنبيه مجتمعي", "Community alert"),
            message: L(
                "إفطار مجاني اليوم بعد المغرب في المسجد.",
                "Free iftar today after Maghrib at the masjid."
            ),
            primaryAction: L("عرض التفاصيل", "View details"),
            secondaryAction: nil,
            accent: .blue
        )
    }

    // MARK: - Faith Card
    private var liveFaithCard: some View {
        LiveCard(
            icon: "moon.stars.fill",
            title: L("تنبيه مرتبط بالصلاة", "Faith-based alert"),
            message: L(
                "بعد صلاة الجمعة: 3 فرص عمل قريبة منك.",
                "After Jumu’ah: 3 job opportunities near you."
            ),
            primaryAction: L("عرض الوظائف", "View jobs"),
            secondaryAction: nil,
            accent: .purple
        )
    }
}

// MARK: - Reusable Live Card

private struct LiveCard: View {

    let icon: String
    let title: String
    let message: String
    let primaryAction: String
    let secondaryAction: String?
    let accent: Color

    var body: some View {
        VStack(spacing: 16) {

            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(accent)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                Button(primaryAction) {
                    // TODO: Action
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(accent)
                .foregroundColor(.white)
                .cornerRadius(14)

                if let secondaryAction {
                    Button(secondaryAction) {
                        // TODO: Action
                    }
                    .font(.footnote)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8)
    }
}

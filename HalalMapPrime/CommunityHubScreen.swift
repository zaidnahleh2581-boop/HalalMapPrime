//
//  CommunityHubScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct CommunityHubScreen: View {

    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    Text(L("المجتمع", "Community"))
                        .font(.title2.bold())
                        .padding(.top, 8)

                    Text(L(
                        "هنا سنضيف لاحقاً: منشورات المجتمع، فعاليات، تنبيهات، وأماكن مهمة.",
                        "Later we will add: community posts, events, alerts, and important places."
                    ))
                    .foregroundColor(.secondary)

                    // ✅ زر/كرت "المزيد" (منقول من TabBar إلى المجتمع)
                    NavigationLink {
                        MoreScreen()
                            .environmentObject(lang)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 22))
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .foregroundColor(.secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(L("المزيد", "More"))
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(L("الخصوصية • الشروط • تواصل معنا", "Privacy • Terms • Contact"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)

                    // Placeholder cards
                    VStack(spacing: 12) {
                        placeholderCard(
                            title: L("منشورات المجتمع", "Community Posts"),
                            subtitle: L("قريباً", "Coming soon"),
                            icon: "text.bubble.fill"
                        )

                        placeholderCard(
                            title: L("الفعاليات", "Events"),
                            subtitle: L("قريباً", "Coming soon"),
                            icon: "calendar"
                        )

                        placeholderCard(
                            title: L("تنبيهات مهمة", "Important Alerts"),
                            subtitle: L("قريباً", "Coming soon"),
                            icon: "bell.fill"
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func placeholderCard(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .frame(width: 36, height: 36)
                .background(Color(.systemGray6))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

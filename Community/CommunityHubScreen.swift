//
//  CommunityHubScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct CommunityHubScreen: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @State private var showComposer: Bool = false
    @State private var showMyEvents: Bool = false

    @State private var selectedCategory: CoreEventCategory = .all

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Top Bar (Contact + Privacy)
                HStack {
                    NavigationLink {
                        ContactUsView()
                            .environmentObject(lang)
                    } label: {
                        Text(L("اتصل بنا", "Contact Us"))
                            .font(.footnote.weight(.semibold))
                    }

                    Spacer()

                    NavigationLink {
                        PrivacyPolicyView()
                            .environmentObject(lang)
                    } label: {
                        Text(L("الخصوصية", "Privacy"))
                            .font(.footnote.weight(.semibold))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // ✅ Core 10 Tabs (fixed)
                coreCategoryTabs
                    .padding(.top, 10)
                    .padding(.bottom, 6)

                // Main content (events list filtered)
                EventAdsBoardView(selectedCategory: selectedCategory)
                    .environmentObject(lang)
            }
            .navigationTitle(L("فعاليات المجتمع", "Community Events"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // ✅ My Events + Add
                ToolbarItemGroup(placement: .topBarTrailing) {

                    Button {
                        showMyEvents = true
                    } label: {
                        Label(L("فعالياتي", "My Events"), systemImage: "person.crop.circle")
                    }

                    Button {
                        showComposer = true
                    } label: {
                        Label(L("أضف", "Add"), systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showComposer) {
                EventAdComposerView()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showMyEvents) {
                MyEventsView()
                    .environmentObject(lang)
            }
        }
    }

    // MARK: - Tabs UI

    private var coreCategoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CoreEventCategory.allCases) { cat in
                    let title = lang.isArabic ? cat.title.ar : cat.title.en

                    Button {
                        selectedCategory = cat
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Text(title)
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(selectedCategory == cat ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == cat
                                          ? Color.blue
                                          : Color(.secondarySystemGroupedBackground))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

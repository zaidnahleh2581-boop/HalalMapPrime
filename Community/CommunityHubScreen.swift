//
//  CommunityHubScreen.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-29.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct CommunityHubScreen: View {

    @EnvironmentObject var lang: LanguageManager

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @State private var showComposer: Bool = false

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

                // Main content
                EventAdsBoardView()
                    .environmentObject(lang)
            }
            .navigationTitle(L("فعاليات المجتمع", "Community Events"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
        }
    }
}

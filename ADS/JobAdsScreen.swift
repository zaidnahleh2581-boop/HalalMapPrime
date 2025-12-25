//
//  JobAdsScreen.swift
//  HalalMapPrime
//
//  Created for: Halal Map Prime
//  Created by: Zaid Nahleh
//  Copyright © 2025 Halal Map Prime. All rights reserved.
//

import SwiftUI

struct JobAdsScreen: View {

    @EnvironmentObject var lang: LanguageManager
    @StateObject private var service = JobAdsService.shared

    var body: some View {
        NavigationStack {
            Group {
                if service.isLoading && service.ads.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if service.ads.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)

                        Text(lang.isArabic ? "لا توجد إعلانات وظائف بعد" : "No job ads yet")
                            .font(.title3.bold())

                        Text(lang.isArabic ?
                             "عندما يقوم أصحاب المحلات أو الباحثون عن عمل بنشر إعلاناتهم، ستظهر هنا." :
                             "Once people start posting job ads, they will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(service.ads) { ad in
                        jobAdRow(ad)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(lang.isArabic ? "إعلانات الوظائف" : "Job ads")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        JobAdComposerView()
                            .environmentObject(lang)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .onAppear { service.startListening() }
            .onDisappear { service.stopListening() }
        }
    }

    @ViewBuilder
    private func jobAdRow(_ ad: JobAd) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ad.title)
                    .font(.headline)

                Spacer()

                Text(lang.isArabic ? ad.type.localizedTitleArabic
                                   : ad.type.localizedTitleEnglish)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ad.type == .hiring
                                ? Color.green.opacity(0.15)
                                : Color.blue.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(ad.details)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            HStack(spacing: 12) {
                Label(ad.city, systemImage: "mappin.and.ellipse")
                Label(ad.contact, systemImage: "phone.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }
}

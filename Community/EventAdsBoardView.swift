//
//  EventAdsBoardView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-29.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct EventAdsBoardView: View {

    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    let selectedCategory: CoreEventCategory

    @StateObject private var vm = EventAdsBoardViewModel()

    @State private var editingAd: EventAd? = nil
    @State private var showEditSheet: Bool = false

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }

    var body: some View {
        Group {
            if vm.isLoading {
                VStack(spacing: 10) {
                    ProgressView()
                    Text(L("جاري تحميل الفعاليات…", "Loading events…"))
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if let err = vm.errorMessage {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.orange)

                    Text(L("حدث خطأ", "Something went wrong"))
                        .font(.headline)

                    Text(err)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(L("إعادة المحاولة", "Try again")) {
                        vm.start()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                List {
                    // ✅ Filtered list based on selectedCategory
                    let items = vm.filteredEvents(for: selectedCategory)

                    if items.isEmpty {
                        emptyStateForCategory(selectedCategory)
                            .listRowSeparator(.hidden)

                    } else {
                        ForEach(items) { ev in
                            VStack(alignment: .leading, spacing: 6) {

                                HStack {
                                    Text(ev.title)
                                        .font(.headline)

                                    Spacer()

                                    Text(dateFormatter.string(from: ev.date))
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }

                                Text("\(ev.city) • \(ev.placeName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(ev.description)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                                if !ev.phone.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "phone.fill")
                                        Text(ev.phone)
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                }

                                // Optional badge for paid
                                if ev.tier.lowercased() == "paid" {
                                    Text(L("مميز", "Featured"))
                                        .font(.caption2.weight(.bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.black.opacity(0.78))
                                        .clipShape(Capsule())
                                        .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 8)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if vm.isOwner(ev) {
                                    Button {
                                        editingAd = ev
                                        showEditSheet = true
                                    } label: {
                                        Label(L("تعديل", "Edit"), systemImage: "pencil")
                                    }
                                    .tint(.blue)

                                    Button(role: .destructive) {
                                        vm.delete(ev)
                                    } label: {
                                        Label(L("حذف", "Delete"), systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear { vm.start() }
        .sheet(isPresented: $showEditSheet) {
            if let ad = editingAd {
                EventAdComposerView(editingAd: ad)
                    .environmentObject(lang)
            }
        }
    }

    private func emptyStateForCategory(_ cat: CoreEventCategory) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.blue.opacity(0.85))

            let title = lang.isArabic ? cat.title.ar : cat.title.en
            Text(L(
                "لا توجد فعاليات ضمن هذا القسم الآن.\nاضغط زر (أضف) لإضافة فعالية.",
                "No events in this category right now.\nTap (Add) to post an event."
            ))
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding(.top, 6)

            Text(L("القسم: \(title)", "Category: \(title)"))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }
}

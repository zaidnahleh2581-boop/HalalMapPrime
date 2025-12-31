//
//  MyEventsView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct MyEventsView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @StateObject private var vm = MyEventsViewModel()

    @State private var editingAd: EventAd? = nil
    @State private var showEditSheet: Bool = false

    private var df: DateFormatter {
        let d = DateFormatter()
        d.dateStyle = .medium
        d.timeStyle = .none
        return d
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                        Text(L("جاري تحميل فعالياتك…", "Loading your events…"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
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

                } else if vm.myEvents.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 44))
                            .foregroundColor(.blue.opacity(0.85))

                        Text(L("لا يوجد لديك فعاليات بعد.", "You haven’t posted any events yet."))
                            .foregroundColor(.secondary)

                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else {
                    List {
                        ForEach(vm.myEvents) { ev in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(ev.title)
                                        .font(.headline)
                                    Spacer()
                                    Text(df.string(from: ev.date))
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }

                                Text("\(ev.city) • \(ev.placeName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                // Tier badge
                                HStack(spacing: 8) {
                                    if ev.tier.lowercased() == "paid" {
                                        Text(L("مميز", "Featured"))
                                            .font(.caption2.weight(.bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.black.opacity(0.78))
                                            .clipShape(Capsule())
                                    } else {
                                        Text(L("مجاني", "Free"))
                                            .font(.caption2.weight(.bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.gray.opacity(0.75))
                                            .clipShape(Capsule())
                                    }

                                    Spacer()
                                }
                                .padding(.top, 2)
                            }
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {

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
                    .listStyle(.plain)
                }
            }
            .navigationTitle(L("فعالياتي", "My Events"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
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
    }
}

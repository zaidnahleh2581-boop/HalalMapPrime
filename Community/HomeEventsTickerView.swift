//
//  HomeEventsTickerView.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI
import Combine
import FirebaseFirestore

struct HomeEventsTickerView: View {

    @EnvironmentObject var lang: LanguageManager
    @EnvironmentObject var router: AppRouter

    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    @StateObject private var vm = HomeEventsTickerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(L("فعاليات قربك", "Events near you"))
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Button {
                    router.selectedTab = 3
                } label: {
                    Text(L("عرض الكل", "View all"))
                        .font(.footnote.weight(.semibold))
                }
            }

            Button {
                router.selectedTab = 3
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .imageScale(.small)

                    if let text = vm.currentTickerText(langIsArabic: lang.isArabic) {
                        MarqueeText(text: text, font: .footnote, speed: 32)
                            .foregroundColor(.primary)
                    } else {
                        Text(L("لا توجد فعاليات مميزة حالياً.", "No featured events yet."))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
            .buttonStyle(.plain)
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

@MainActor
final class HomeEventsTickerViewModel: ObservableObject {

    @Published private(set) var paidUpcoming: [EventAd] = []
    @Published private(set) var tickerIndex: Int = 0

    private var listener: ListenerRegistration?
    private var timer: Timer?

    func start() {
        startListening()
        startTimer()
    }

    func stop() {
        listener?.remove()
        listener = nil
        timer?.invalidate()
        timer = nil
    }

    deinit {
        // ✅ deinit is not MainActor-isolated, so keep it simple & safe
        listener?.remove()
        timer?.invalidate()
    }

    private func startListening() {
        listener?.remove()

        listener = EventAdsService.shared.observeUpcomingEvents { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                switch result {
                case .failure:
                    self.paidUpcoming = []
                    self.tickerIndex = 0

                case .success(let allUpcoming):
                    // ✅ Paid-only for Home
                    let paid = allUpcoming.filter { $0.tier.lowercased() == "paid" }
                    self.paidUpcoming = paid

                    if self.tickerIndex >= paid.count {
                        self.tickerIndex = 0
                    }
                }
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()

        // ✅ Quiet rotation (not every minute)
        timer = Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { [weak self] _ in
            guard let self else { return }

            Task { @MainActor in
                guard !self.paidUpcoming.isEmpty else { return }
                self.tickerIndex = (self.tickerIndex + 1) % self.paidUpcoming.count
            }
        }
    }

    func currentTickerText(langIsArabic: Bool) -> String? {
        guard !paidUpcoming.isEmpty else { return nil }

        let ev = paidUpcoming[min(tickerIndex, paidUpcoming.count - 1)]

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none

        let dateText = df.string(from: ev.date)
        return "\(ev.title) — \(ev.city) — \(dateText)"
    }
}

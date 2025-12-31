//
//  EventAdsBoardViewModel.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-29.
//  Updated by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class EventAdsBoardViewModel: ObservableObject {

    @Published private(set) var events: [EventAd] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func start() {
        isLoading = true
        errorMessage = nil

        listener?.remove()
        listener = EventAdsService.shared.observeUpcomingEvents { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                self.isLoading = false

                switch result {
                case .success(let items):
                    self.events = items
                case .failure(let error):
                    self.events = []
                    self.errorMessage = self.prettyError(error)
                }
            }
        }
    }

    func filteredEvents(for category: CoreEventCategory) -> [EventAd] {
        // Filter by core category mapping (no DB changes)
        let base = events.filter { $0.deletedAt == nil }
        return base.filter { category.matches(event: $0) }
    }

    func isOwner(_ ad: EventAd) -> Bool {
        Auth.auth().currentUser?.uid == ad.ownerId
    }

    func delete(_ ad: EventAd) {
        EventAdsService.shared.softDeleteEventAd(
            adId: ad.id,
            ownerId: ad.ownerId
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.errorMessage = self.prettyError(error)
                }
            }
        }
    }

    // MARK: - Helpers

    private func prettyError(_ error: Error) -> String {
        let msg = error.localizedDescription.lowercased()

        if msg.contains("missing or insufficient permissions") {
            return "ليس لديك صلاحية لهذه العملية. تأكد أنك نفس المستخدم الذي أنشأ الإعلان."
        }

        if msg.contains("requires an index") {
            return "الاستعلام يحتاج Index في Firestore. افتح رابط الـ Index من الكونسول وأنشئه."
        }

        return error.localizedDescription
    }
}

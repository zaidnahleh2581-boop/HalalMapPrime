//
//  EventAdsBoardViewModel.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/29/25.
//

import Foundation
import Combine          // ⬅️ هذا السطر هو الحل
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class EventAdsBoardViewModel: ObservableObject {

    @Published var events: [EventAd] = []
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
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let items):
                    self.events = items
                case .failure(let error):
                    self.events = []
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func isOwner(_ ad: EventAd) -> Bool {
        Auth.auth().currentUser?.uid == ad.ownerId
    }

    func delete(_ ad: EventAd) {
        EventAdsService.shared.softDeleteEventAd(adId: ad.id) { _ in }
    }
}

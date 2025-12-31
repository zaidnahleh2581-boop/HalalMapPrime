//
//  MyEventsViewModel.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-31.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class MyEventsViewModel: ObservableObject {

    @Published private(set) var myEvents: [EventAd] = []
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
        listener = EventAdsService.shared.observeMyEvents { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let items):
                    self.myEvents = items
                case .failure(let error):
                    self.myEvents = []
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func delete(_ ad: EventAd) {
        EventAdsService.shared.softDeleteEventAd(
            adId: ad.id,
            ownerId: ad.ownerId
        ) { [weak self] res in
            guard let self else { return }
            Task { @MainActor in
                if case .failure(let err) = res {
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
}

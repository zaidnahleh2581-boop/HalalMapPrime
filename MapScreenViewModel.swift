//
//  MapScreenViewModel.swift
//  Halal Map Prime
//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-25.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import MapKit
import SwiftUI
import Combine

@MainActor
final class MapScreenViewModel: ObservableObject {

    // MARK: - Published
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @Published var places: [Place] = []
    @Published var filteredPlaces: [Place] = []
    @Published var isLoading: Bool = false
    @Published var lastErrorMessage: String? = nil

    // MARK: - Init
    init() {
        loadInitialData()
    }

    // MARK: - Initial Load
    func loadInitialData() {
        isLoading = true
        lastErrorMessage = nil

        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: nil
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = loaded
                case .failure(let error):
                    self.places = []
                    self.filteredPlaces = []
                    self.lastErrorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Search Nearby by Category (Google)
    func searchNearby(category: PlaceCategory?) {
        isLoading = true
        lastErrorMessage = nil

        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: category
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = loaded
                case .failure(let error):
                    self.places = []
                    self.filteredPlaces = []
                    self.lastErrorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - ✅ REQUIRED by MapScreen (Fixes your 3 errors)
    /// Yelp-style search:
    /// - If query is empty → reload nearby for selected category
    /// - Else → filter locally inside already loaded places (name/address)
    func searchByText(
        query: String,
        category: PlaceCategory?,
        completion: @escaping (Result<[Place], Error>) -> Void
    ) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // لو فاضي: رجّع تحميل قريب
        guard !q.isEmpty else {
            searchNearby(category: category)
            completion(.success(filteredPlaces))
            return
        }

        // بحث محلي داخل النتائج الحالية (آمن + سريع)
        filterBySearch(text: q)
        completion(.success(filteredPlaces))
    }

    // MARK: - Local Filter
    func filterBySearch(text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !q.isEmpty else {
            filteredPlaces = places
            return
        }

        filteredPlaces = places.filter {
            $0.name.lowercased().contains(q) ||
            $0.address.lowercased().contains(q)
        }
    }

    // MARK: - Focus Map
    func focus(on place: Place) {
        withAnimation {
            region = MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}

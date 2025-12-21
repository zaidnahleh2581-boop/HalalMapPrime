//
//  MapScreenViewModel.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh
//  Fixed & Stabilized on 12/21/25
//

import Foundation
import MapKit
import Combine
import SwiftUI

final class MapScreenViewModel: ObservableObject {

    // MARK: - Published
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @Published var places: [Place] = []
    @Published var filteredPlaces: [Place] = []

    // MARK: - Init
    init() {
        loadInitialData()
    }

    // MARK: - Load Google Places
    func loadInitialData() {
        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = loaded
                case .failure(let error):
                    print("❌ Google load error:", error)
                }
            }
        }
    }

    // MARK: - Category Search
    func searchNearby(category: PlaceCategory?) {
        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: category
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = loaded
                case .failure(let error):
                    print("❌ Category search error:", error)
                }
            }
        }
    }

    // MARK: - Text Filter
    func filterBySearch(text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            filteredPlaces = places
        } else {
            filteredPlaces = places.filter {
                $0.name.lowercased().contains(q)
            }
        }
    }

    // MARK: - Focus
    func focus(on place: Place) {
        withAnimation {
            region = MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}

import Foundation
import MapKit
import Combine
import SwiftUI

final class MapScreenViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @Published var places: [Place] = []
    @Published var filteredPlaces: [Place] = []

    init() {
        loadInitialData()
    }

    // MARK: - Load initial Google data
    func loadInitialData() {
        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = loaded
                    print("[MapScreenViewModel] Loaded \(loaded.count) places")
                case .failure(let error):
                    print("❌ Error: \(error)")
                }
            }
        }
    }

    // MARK: - Search by Category
    func searchNearby(category: PlaceCategory?) {
        GooglePlacesService.shared.searchNearbyHalal(
            coordinate: region.center,
            category: category
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loaded):
                    self.places = loaded
                    self.filteredPlaces = loaded
                case .failure(let error):
                    print("❌ Category search error: \(error)")
                }
            }
        }
    }

    // MARK: - Filter by Search Text
    func filterBySearch(text: String) {
        if text.isEmpty {
            filteredPlaces = places
        } else {
            filteredPlaces = places.filter {
                $0.name.lowercased().contains(text.lowercased())
            }
        }
    }

    // MARK: - Focus map on selected place
    func focus(on place: Place) {
        withAnimation {
            region = MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}

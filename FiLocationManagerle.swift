//
//  FiLocationManagerle.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 12/24/25.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var authorization: CLAuthorizationStatus
    @Published var lastLocation: CLLocation?

    private let manager = CLLocationManager()

    override init() {
        self.authorization = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    var isAuthorized: Bool {
        authorization == .authorizedWhenInUse || authorization == .authorizedAlways
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestOneTimeLocation() {
        guard isAuthorized else { return }
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorization = manager.authorizationStatus
            if self.isAuthorized {
                self.requestOneTimeLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.lastLocation = locations.last
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // ما نكسر التطبيق، بس نسجل
        print("❌ Location error:", error.localizedDescription)
    }
}

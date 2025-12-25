//
//  AppLocationManager.swift
//  HalalMapPrime
//
//  Created by Zaid Nahleh on 2025-12-24.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class AppLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var lastLocation: CLLocation?

    private let manager = CLLocationManager()

    // يمنع تكرار الطلب/التحديث
    private var didRequestAuth = false
    private var didRequestLocation = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
        authorizationStatus = manager.authorizationStatus
    }

    // MARK: - Public API

    /// استدعِ هذه مرة واحدة من شاشة "طلب الإذن"
    func requestWhenInUseAuthorizationIfNeeded() {
        guard !didRequestAuth else { return }
        didRequestAuth = true
        manager.requestWhenInUseAuthorization()
    }

    /// استدعِ هذه بعد ما تكون الصلاحية Authorized
    /// بتجيب Location مرة واحدة (خفيفة) بدل ما تضل Updating
    func requestSingleLocationIfPossible() {
        let status = manager.authorizationStatus
        authorizationStatus = status

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return
        }

        guard !didRequestLocation else { return }
        didRequestLocation = true

        // أهم شيء: لا تستخدم startUpdatingLocation هنا
        manager.requestLocation()
    }

    /// إذا بدك تسمح بإعادة المحاولة يدويًا (زر "Try Again")
    func retryLocation() {
        didRequestLocation = false
        requestSingleLocationIfPossible()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        // أول ما يصير Authorized جيب Location مرة واحدة
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            requestSingleLocationIfPossible()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last

        // أمان إضافي: أوقف أي تحديثات لو كانت شغالة بسبب شيء ثاني
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 Location error:", error.localizedDescription)
    }
}

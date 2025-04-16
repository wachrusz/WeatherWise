//
//  HomeView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import CoreLocation
import Combine
import SwiftUI

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var onAuthorizationDenied: (() -> Void)?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        authorizationStatus = manager.authorizationStatus
        print("authorizationStatus: \(authorizationStatus)")
        loadSavedLocation()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkAuthorizationStatus()
        }
    }
    
    func checkAuthorizationStatus() {
        let currentStatus = manager.authorizationStatus
        authorizationStatus = currentStatus
        
        switch currentStatus {
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            onAuthorizationDenied?()
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocation()
        @unknown default:
            break
        }
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        guard manager.authorizationStatus == .authorizedAlways ||
              manager.authorizationStatus == .authorizedWhenInUse else {
            onAuthorizationDenied?()
            return
        }
        manager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        saveCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        print("Current auth status: \(newStatus.rawValue)")
        authorizationStatus = newStatus
        
        switch newStatus {
        case .denied, .restricted:
            print("Location access denied")
            onAuthorizationDenied?()
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location access granted")
            requestLocation()
        default:
            break
        }
    }
    
    func saveCurrentLocation() {
        guard let location = currentLocation else { return }
        let lastLocation = LastLocation(location: location)
        
        do {
            try RealmManager.shared.saveLocation(lastLocation)
            print("Saved location: \(lastLocation.coordinate)")
        } catch {
            print("Failed to save location: \(error)")
        }
    }
    
    func loadSavedLocation() {
        let savedLocations = RealmManager.shared.getSavedLocations()
        if let saved = savedLocations?.first {
            currentLocation = CLLocation(latitude: saved.latitude, longitude: saved.longitude)
            print("Loaded saved location: \(saved.coordinate)")
        } else {
            print("No saved location found.")
        }
    }

}

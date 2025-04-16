//
//  MapViewModel.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 15.04.2025.
//

import Foundation
import MapKit
import Combine

final class MapViewModel: NSObject, ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let defaultLocation: CLLocationCoordinate2D
    private let locationManager = LocationManager.shared
    private let sharedLocationData = SharedLocationData.shared
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.defaultLocation = LocationManager.shared.currentLocation?.coordinate ??
            CLLocationCoordinate2D(latitude: 37.785834, longitude: -122.406417)
        
        self.region = MKCoordinateRegion(
            center: defaultLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        
        super.init()
        
        setupSubscriptions()
        checkLocationAuthorization()
    }
    
    private func setupSubscriptions() {
        locationManager.$currentLocation
            .compactMap { $0?.coordinate }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                self?.region.center = coordinate
                self?.selectedCoordinate = coordinate
            }
            .store(in: &cancellables)
        
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .assign(to: \.authorizationStatus, on: self)
            .store(in: &cancellables)
        
        sharedLocationData.$selectedRegion
            .receive(on: DispatchQueue.main)
            .assign(to: \.region, on: self)
            .store(in: &cancellables)
    }
    
    func resetToDefaultLocation() {
        region = MKCoordinateRegion(
            center: defaultLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestPermission()
        case .restricted, .denied:
            print("Location access denied")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    func handleMapTap(coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
    }
}

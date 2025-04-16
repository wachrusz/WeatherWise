//
//  MapView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 15.04.2025.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel = MapViewModel()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap)
        )
        mapView.addGestureRecognizer(tapGesture)
        
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = .clear
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(buttonContainer)
        
        let locationButton = MKUserTrackingButton(mapView: mapView)
        locationButton.layer.backgroundColor = UIColor(AppColors.bg1).cgColor
        locationButton.layer.cornerRadius = 5
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        
        if let button = locationButton.subviews.first as? UIButton {
            button.tintColor = UIColor(AppColors.fg1)
            button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        buttonContainer.addSubview(locationButton)
        
        NSLayoutConstraint.activate([
            buttonContainer.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 100),
            buttonContainer.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            buttonContainer.widthAnchor.constraint(equalToConstant: 44),
            buttonContainer.heightAnchor.constraint(equalToConstant: 44),
            
            locationButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            locationButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            locationButton.widthAnchor.constraint(equalToConstant: 44),
            locationButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let newCenter = viewModel.region.center
        let currentCenter = uiView.region.center
        
        if abs(newCenter.latitude - currentCenter.latitude) > 1e-6 ||
           abs(newCenter.longitude - currentCenter.longitude) > 1e-6 {
            uiView.setRegion(viewModel.region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func handleTap(gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.viewModel.handleMapTap(coordinate: coordinate)
        }
    }
}

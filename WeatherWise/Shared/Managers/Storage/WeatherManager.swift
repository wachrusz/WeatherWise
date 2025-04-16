//
//  WeatherManager.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 15.04.2025.
//

import Foundation

final class WeatherDataService {
    static let shared = WeatherDataService()
    
    @Published var weather: WeatherData?
    private init() {}
}

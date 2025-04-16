//
//  WeatherViewModel.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 15.04.2025.
//

import Foundation
import Combine
import SwiftUI

final class WeatherViewModel: ObservableObject {
    @Published var weather: CurrentWeather?
    @Published var dailyForecast: DailyForecast?
    @Published var isLoading = false
    @Published var isExpanded = false
    @Published var error: String?
    
    private let dataService = WeatherDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    
    var temperatureChartData: [CGPoint] {
        guard let dailyData = dailyForecast?.data else { return [] }
        
        let maxTemp = dailyData.map { Int($0.temperatureMax ?? 0) }.max() ?? 0
        let minTemp = dailyData.map { Int($0.temperatureMin ?? 0) }.min() ?? 0
        let tempRange = maxTemp - minTemp
        
        return dailyData.enumerated().map { index, data in
            let x = CGFloat(index) / CGFloat(dailyData.count - 1)
            let y = CGFloat((Int(data.temperatureMax ?? 0) - minTemp) / tempRange)
            return CGPoint(x: x, y: y)
        }
    }
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        dataService.$weather
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newWeather in
                self?.weather = newWeather?.currently
                self?.dailyForecast = newWeather?.daily
            }
            .store(in: &cancellables)
    }
    
    func toggle() {
        withAnimation(.spring()) {
            isExpanded.toggle()
        }
    }

}


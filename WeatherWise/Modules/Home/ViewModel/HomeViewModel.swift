//
//  HomeView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import Foundation
import Combine
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showLocationAlert = false {
        didSet {
            if showLocationAlert {
                error = "Не удалось определить местоположение"
            }
        }
    }
    
    init() {
        LocationManager.shared.onAuthorizationDenied = { [weak self] in
            DispatchQueue.main.async {
                self?.showLocationAlert = true
            }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    func loadWeather() {
        isLoading = true
        
        loadWeatherFromCache()
        
        guard LocationManager.shared.authorizationStatus == .authorizedWhenInUse ||
              LocationManager.shared.authorizationStatus == .authorizedAlways else {
            handleError(WeatherError.locationUnavailable)
            return
        }
        
        LocationManager.shared.$currentLocation
            .first(where: { $0 != nil })
            .sink { [weak self] location in
                guard let self, let location else {
                    self?.handleError(WeatherError.locationUnavailable)
                    return
                }
                
                WeatherAPIManager.shared.fetchWeather(location: location) { result in
                    switch result {
                    case .success(let weather):
                        self.updateUI(with: weather)
                    case .failure(let error):
                        self.handleError(error)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with weather: WeatherResponse) {
        DispatchQueue.main.async {
            self.weather = weather
            self.isLoading = false
            self.error = nil
            
            // Сохраняем данные в кэш
            self.saveWeatherToCache(weather)
            
            WeatherDataService.shared.weather = self.weather?.data
            print("Данные обновлены:")
            print("- Температура: \(weather.data.currently.temperature)°C")
            print("- Иконка: \(weather.data.currently.icon)")
        }
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            
            if let weatherError = error as? WeatherError {
                switch weatherError {
                case .locationUnavailable:
                    self.error = "Не удалось определить местоположение"
                    self.showLocationAlert = true
                case .apiError(let message):
                    self.error = "Ошибка API: \(message)"
                case .decodingError:
                    self.error = "Ошибка формата данных"
                case .networkError:
                    self.error = "Проблемы с интернет-соединением"
                }
            } else {
                self.error = error.localizedDescription
            }
            
            print("Ошибка: \(self.error ?? "Unknown error")")
        }
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func saveWeatherToCache(_ weather: WeatherResponse) {
        let cachedWeather = CachedWeather(weatherResponse: weather)
        RealmManager.shared.saveCachedWeather(cachedWeather)
        print("Weather data saved to cache.")
    }
    
    func loadWeatherFromCache() {
        if let cachedWeather = RealmManager.shared.getCachedWeather() {
            guard let cachedData = cachedWeather.weatherData else {
                print("No cached weather data available.")
                return
            }

            let weatherData = convertToWeatherData(from: cachedData)

            self.weather = WeatherResponse(success: true, data: weatherData)
            print("Loaded weather data from cache.")
        } else {
            print("No cached weather data found.")
        }
    }


}

func convertToCurrentWeather(from cachedCurrentWeather: CachedCurrentWeather) -> CurrentWeather {
    return CurrentWeather(
        apparentTemperature: cachedCurrentWeather.apparentTemperature,
        cloudCover: cachedCurrentWeather.cloudCover,
        dewPoint: cachedCurrentWeather.dewPoint,
        humidity: cachedCurrentWeather.humidity,
        icon: cachedCurrentWeather.icon,
        precipIntensity: cachedCurrentWeather.precipIntensity,
        pressure: cachedCurrentWeather.pressure,
        temperature: cachedCurrentWeather.temperature,
        uvIndex: cachedCurrentWeather.uvIndex,
        visibility: cachedCurrentWeather.visibility,
        windDirection: cachedCurrentWeather.windDirection,
        windGust: cachedCurrentWeather.windGust,
        windSpeed: cachedCurrentWeather.windSpeed
    )
}

func convertToWeatherData(from cachedData: CachedWeatherData) -> WeatherData {
    return WeatherData(
        dt: cachedData.dt,
        latitude: cachedData.latitude,
        longitude: cachedData.longitude,
        timezone: cachedData.timezone,
        timezoneAbbreviation: cachedData.timezoneAbbreviation,
        timezoneOffset: cachedData.timezoneOffset,
        units: cachedData.units,
        currently: convertToCurrentWeather(from: cachedData.currently ?? CachedCurrentWeather()),
        hourly: HourlyForecast(data: Array(cachedData.hourly.map { convertToHourlyData(from: $0) })),
        daily: DailyForecast(data: Array(cachedData.daily.map { convertToDailyData(from: $0) }))
    )
}

func convertToHourlyData(from cachedHourlyData: CachedHourlyData) -> HourlyData {
    return HourlyData(
        apparentTemperature: cachedHourlyData.apparentTemperature,
        cloudCover: cachedHourlyData.cloudCover,
        dewPoint: cachedHourlyData.dewPoint,
        forecastStart: cachedHourlyData.forecastStart,
        humidity: cachedHourlyData.humidity,
        icon: cachedHourlyData.icon,
        precipIntensity: cachedHourlyData.precipIntensity,
        precipProbability: cachedHourlyData.precipProbability,
        pressure: cachedHourlyData.pressure,
        temperature: cachedHourlyData.temperature,
        uvIndex: cachedHourlyData.uvIndex,
        visibility: cachedHourlyData.visibility,
        windDirection: cachedHourlyData.windDirection,
        windGust: cachedHourlyData.windGust,
        windSpeed: cachedHourlyData.windSpeed
    )
}

func convertToDailyData(from cachedDailyData: CachedDailyData) -> DailyData {
    return DailyData(
        apparentTemperatureAvg: cachedDailyData.apparentTemperatureAvg,
        apparentTemperatureMax: cachedDailyData.apparentTemperatureMax,
        apparentTemperatureMin: cachedDailyData.apparentTemperatureMin,
        cloudCover: cachedDailyData.cloudCover,
        dewPointAvg: cachedDailyData.dewPointAvg,
        dewPointMax: cachedDailyData.dewPointMax,
        dewPointMin: cachedDailyData.dewPointMin,
        forecastEnd: cachedDailyData.forecastEnd,
        forecastStart: cachedDailyData.forecastStart,
        humidity: cachedDailyData.humidity,
        icon: cachedDailyData.icon,
        moonPhase: cachedDailyData.moonPhase,
        precipIntensity: cachedDailyData.precipIntensity,
        precipProbability: cachedDailyData.precipProbability,
        pressure: cachedDailyData.pressure,
        sunriseTime: cachedDailyData.sunriseTime,
        sunsetTime: cachedDailyData.sunsetTime,
        temperatureAvg: cachedDailyData.temperatureAvg,
        temperatureMax: cachedDailyData.temperatureMax,
        temperatureMin: cachedDailyData.temperatureMin,
        uvIndexMax: cachedDailyData.uvIndexMax,
        visibility: cachedDailyData.visibility,
        windDirectionAvg: cachedDailyData.windDirectionAvg,
        windGustAvg: cachedDailyData.windGustAvg,
        windGustMax: cachedDailyData.windGustMax,
        windGustMin: cachedDailyData.windGustMin,
        windSpeedAvg: cachedDailyData.windSpeedAvg,
        windSpeedMax: cachedDailyData.windSpeedMax,
        windSpeedMin: cachedDailyData.windSpeedMin
    )
}

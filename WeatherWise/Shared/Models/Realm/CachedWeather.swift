//
//  CachedWeather.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 16.04.2025.
//

import RealmSwift
import CoreLocation

// MARK: - Кешированные погодные данные
final class CachedWeather: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var timestamp: Date = Date()
    @Persisted var weatherData: CachedWeatherData?
    
    convenience init(weatherResponse: WeatherResponse) {
        self.init()
        self.weatherData = CachedWeatherData(from: weatherResponse.data)
    }
}

final class CachedWeatherData: Object {
    @Persisted var dt: TimeInterval = 0
    @Persisted var latitude: Double = 0
    @Persisted var longitude: Double = 0
    @Persisted var timezone: String = ""
    @Persisted var timezoneAbbreviation: String = ""
    @Persisted var timezoneOffset: Int = 0
    @Persisted var units: String = ""
    @Persisted var currently: CachedCurrentWeather?
    @Persisted var hourly: List<CachedHourlyData>
    @Persisted var daily: List<CachedDailyData>
    
    convenience init(from weatherData: WeatherData) {
        self.init()
        self.dt = weatherData.dt
        self.latitude = weatherData.latitude
        self.longitude = weatherData.longitude
        self.timezone = weatherData.timezone
        self.timezoneAbbreviation = weatherData.timezoneAbbreviation
        self.timezoneOffset = weatherData.timezoneOffset
        self.units = weatherData.units
        self.currently = CachedCurrentWeather(from: weatherData.currently)
        
        weatherData.hourly.data.forEach { hourlyData in
            self.hourly.append(CachedHourlyData(from: hourlyData))
        }
        
        weatherData.daily.data.forEach { dailyData in
            self.daily.append(CachedDailyData(from: dailyData))
        }
    }
}

final class CachedCurrentWeather: Object {
    @Persisted var apparentTemperature: Double = 0
    @Persisted var cloudCover: Double = 0
    @Persisted var dewPoint: Double = 0
    @Persisted var humidity: Double = 0
    @Persisted var icon: String = ""
    @Persisted var precipIntensity: Double = 0
    @Persisted var pressure: Double = 0
    @Persisted var temperature: Double = 0
    @Persisted var uvIndex: Int = 0
    @Persisted var visibility: Int = 0
    @Persisted var windDirection: Int = 0
    @Persisted var windGust: Double = 0
    @Persisted var windSpeed: Double = 0
    
    convenience init(from currentWeather: CurrentWeather) {
        self.init()
        self.apparentTemperature = currentWeather.apparentTemperature
        self.cloudCover = currentWeather.cloudCover
        self.dewPoint = currentWeather.dewPoint
        self.humidity = currentWeather.humidity
        self.icon = currentWeather.icon
        self.precipIntensity = currentWeather.precipIntensity
        self.pressure = currentWeather.pressure
        self.temperature = currentWeather.temperature
        self.uvIndex = currentWeather.uvIndex
        self.visibility = currentWeather.visibility
        self.windDirection = currentWeather.windDirection
        self.windGust = currentWeather.windGust
        self.windSpeed = currentWeather.windSpeed
    }
}

final class CachedHourlyData: Object {
    @Persisted var apparentTemperature: Double = 0
    @Persisted var cloudCover: Double = 0
    @Persisted var dewPoint: Double = 0
    @Persisted var forecastStart: TimeInterval = 0
    @Persisted var humidity: Double = 0
    @Persisted var icon: String = ""
    @Persisted var precipIntensity: Double = 0
    @Persisted var precipProbability: Double = 0
    @Persisted var pressure: Double = 0
    @Persisted var temperature: Double = 0
    @Persisted var uvIndex: Int = 0
    @Persisted var visibility: Int = 0
    @Persisted var windDirection: Int = 0
    @Persisted var windGust: Double = 0
    @Persisted var windSpeed: Double = 0
    
    convenience init(from hourlyData: HourlyData) {
        self.init()
        self.apparentTemperature = hourlyData.apparentTemperature ?? 0
        self.cloudCover = hourlyData.cloudCover ?? 0
        self.dewPoint = hourlyData.dewPoint
        self.forecastStart = hourlyData.forecastStart
        self.humidity = hourlyData.humidity
        self.icon = hourlyData.icon
        self.precipIntensity = hourlyData.precipIntensity ?? 0
        self.precipProbability = hourlyData.precipProbability ?? 0
        self.pressure = hourlyData.pressure ?? 0
        self.temperature = hourlyData.temperature
        self.uvIndex = hourlyData.uvIndex
        self.visibility = hourlyData.visibility ?? 0
        self.windDirection = hourlyData.windDirection ?? 0
        self.windGust = hourlyData.windGust ?? 0
        self.windSpeed = hourlyData.windSpeed ?? 0
    }
}

final class CachedDailyData: Object {
    @Persisted var apparentTemperatureAvg: Double = 0
    @Persisted var apparentTemperatureMax: Double = 0
    @Persisted var apparentTemperatureMin: Double = 0
    @Persisted var cloudCover: Double = 0
    @Persisted var dewPointAvg: Double = 0
    @Persisted var dewPointMax: Double = 0
    @Persisted var dewPointMin: Double = 0
    @Persisted var forecastEnd: TimeInterval = 0
    @Persisted var forecastStart: TimeInterval = 0
    @Persisted var humidity: Double = 0
    @Persisted var icon: String = ""
    @Persisted var moonPhase: Double = 0
    @Persisted var precipIntensity: Double = 0
    @Persisted var precipProbability: Double = 0
    @Persisted var pressure: Double = 0
    @Persisted var sunriseTime: TimeInterval = 0
    @Persisted var sunsetTime: TimeInterval = 0
    @Persisted var temperatureAvg: Double = 0
    @Persisted var temperatureMax: Double = 0
    @Persisted var temperatureMin: Double = 0
    @Persisted var uvIndexMax: Int = 0
    @Persisted var visibility: Int = 0
    @Persisted var windDirectionAvg: Int = 0
    @Persisted var windGustAvg: Double = 0
    @Persisted var windGustMax: Double = 0
    @Persisted var windGustMin: Double = 0
    @Persisted var windSpeedAvg: Double = 0
    @Persisted var windSpeedMax: Double = 0
    @Persisted var windSpeedMin: Double = 0
    
    convenience init(from dailyData: DailyData) {
        self.init()
        self.apparentTemperatureAvg = dailyData.apparentTemperatureAvg ?? 0
        self.apparentTemperatureMax = dailyData.apparentTemperatureMax ?? 0
        self.apparentTemperatureMin = dailyData.apparentTemperatureMin ?? 0
        self.cloudCover = dailyData.cloudCover ?? 0
        self.dewPointAvg = dailyData.dewPointAvg ?? 0
        self.dewPointMax = dailyData.dewPointMax ?? 0
        self.dewPointMin = dailyData.dewPointMin ?? 0
        self.forecastEnd = dailyData.forecastEnd ?? 0
        self.forecastStart = dailyData.forecastStart ?? 0
        self.humidity = dailyData.humidity ?? 0
        self.icon = dailyData.icon ?? ""
        self.moonPhase = dailyData.moonPhase ?? 0
        self.precipIntensity = dailyData.precipIntensity ?? 0
        self.precipProbability = dailyData.precipProbability ?? 0
        self.pressure = dailyData.pressure ?? 0
        self.sunriseTime = dailyData.sunriseTime ?? 0
        self.sunsetTime = dailyData.sunsetTime ?? 0
        self.temperatureAvg = dailyData.temperatureAvg ?? 0
        self.temperatureMax = dailyData.temperatureMax ?? 0
        self.temperatureMin = dailyData.temperatureMin ?? 0
        self.uvIndexMax = dailyData.uvIndexMax ?? 0
        self.visibility = dailyData.visibility ?? 0
        self.windDirectionAvg = dailyData.windDirectionAvg ?? 0
        self.windGustAvg = dailyData.windGustAvg ?? 0
        self.windGustMax = dailyData.windGustMax ?? 0
        self.windGustMin = dailyData.windGustMin ?? 0
        self.windSpeedAvg = dailyData.windSpeedAvg ?? 0
        self.windSpeedMax = dailyData.windSpeedMax ?? 0
        self.windSpeedMin = dailyData.windSpeedMin ?? 0
    }
}

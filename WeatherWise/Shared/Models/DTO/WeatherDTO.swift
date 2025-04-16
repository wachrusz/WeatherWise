//
//  WeatherDTO.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import Foundation
import SwiftyJSON

// MARK: - Основная модель ответа
struct WeatherResponse: Codable {
    let success: Bool
    let data: WeatherData
    
    enum CodingKeys: String, CodingKey {
        case success = "success"
        case data = "data"
    }
}

// MARK: - Основные данные о погоде
struct WeatherData: Codable {
    let dt: TimeInterval
    let latitude: Double
    let longitude: Double
    let timezone: String
    let timezoneAbbreviation: String
    let timezoneOffset: Int
    let units: String
    let currently: CurrentWeather
    let hourly: HourlyForecast
    let daily: DailyForecast
    
    enum CodingKeys: String, CodingKey {
        case dt = "dt"
        case latitude = "latitude"
        case longitude = "longitude"
        case timezone = "timezone"
        case timezoneAbbreviation = "timezone_abbreviation"
        case timezoneOffset = "timezone_offset"
        case units = "units"
        case currently = "currently"
        case hourly = "hourly"
        case daily = "daily"
    }
}

// MARK: - Текущая погода
struct CurrentWeather: Codable {
    let apparentTemperature: Double
    let cloudCover: Double
    let dewPoint: Double
    let humidity: Double
    let icon: String
    let precipIntensity: Double
    let pressure: Double
    let temperature: Double
    let uvIndex: Int
    let visibility: Int
    let windDirection: Int
    let windGust: Double
    let windSpeed: Double
    
    enum CodingKeys: String, CodingKey {
        case apparentTemperature = "apparentTemperature"
        case cloudCover = "cloudCover"
        case dewPoint = "dewPoint"
        case humidity = "humidity"
        case icon = "icon"
        case precipIntensity = "precipIntensity"
        case pressure = "pressure"
        case temperature = "temperature"
        case uvIndex = "uvIndex"
        case visibility = "visibility"
        case windDirection = "windDirection"
        case windGust = "windGust"
        case windSpeed = "windSpeed"
    }
}

// MARK: - Почасовой прогноз
struct HourlyForecast: Codable {
    let data: [HourlyData]
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct HourlyData: Codable {
    let apparentTemperature: Double?
    let cloudCover: Double?
    let dewPoint: Double
    let forecastStart: TimeInterval
    let humidity: Double
    let icon: String
    let precipIntensity: Double?
    let precipProbability: Double?
    let pressure: Double?
    let temperature: Double
    let uvIndex: Int
    let visibility: Int?
    let windDirection: Int?
    let windGust: Double?
    let windSpeed: Double?
    
    enum CodingKeys: String, CodingKey {
        case apparentTemperature = "apparentTemperature"
        case cloudCover = "cloudCover"
        case dewPoint = "dewPoint"
        case forecastStart = "forecastStart"
        case humidity = "humidity"
        case icon = "icon"
        case precipIntensity = "precipIntensity"
        case precipProbability = "precipProbability"
        case pressure = "pressure"
        case temperature = "temperature"
        case uvIndex = "uvIndex"
        case visibility = "visibility"
        case windDirection = "windDirection"
        case windGust = "windGust"
        case windSpeed = "windSpeed"
    }
}

// MARK: - Дневной прогноз
struct DailyForecast: Codable {
    let data: [DailyData]
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct DailyData: Codable {
    let apparentTemperatureAvg: Double?
    let apparentTemperatureMax: Double?
    let apparentTemperatureMin: Double?
    let cloudCover: Double?
    let dewPointAvg: Double?
    let dewPointMax: Double?
    let dewPointMin: Double?
    let forecastEnd: TimeInterval?
    let forecastStart: TimeInterval?
    let humidity: Double?
    let icon: String?
    let moonPhase: Double?
    let precipIntensity: Double?
    let precipProbability: Double?
    let pressure: Double?
    let sunriseTime: TimeInterval?
    let sunsetTime: TimeInterval?
    let temperatureAvg: Double?
    let temperatureMax: Double?
    let temperatureMin: Double?
    let uvIndexMax: Int?
    let visibility: Int?
    let windDirectionAvg: Int?
    let windGustAvg: Double?
    let windGustMax: Double?
    let windGustMin: Double?
    let windSpeedAvg: Double?
    let windSpeedMax: Double?
    let windSpeedMin: Double?
    
    enum CodingKeys: String, CodingKey {
        case apparentTemperatureAvg = "apparentTemperatureAvg"
        case apparentTemperatureMax = "apparentTemperatureMax"
        case apparentTemperatureMin = "apparentTemperatureMin"
        case cloudCover = "cloudCover"
        case dewPointAvg = "dewPointAvg"
        case dewPointMax = "dewPointMax"
        case dewPointMin = "dewPointMin"
        case forecastEnd = "forecastEnd"
        case forecastStart = "forecastStart"
        case humidity = "humidity"
        case icon = "icon"
        case moonPhase = "moonPhase"
        case precipIntensity = "precipIntensity"
        case precipProbability = "precipProbability"
        case pressure = "pressure"
        case sunriseTime = "sunriseTime"
        case sunsetTime = "sunsetTime"
        case temperatureAvg = "temperatureAvg"
        case temperatureMax = "temperatureMax"
        case temperatureMin = "temperatureMin"
        case uvIndexMax = "uvIndexMax"
        case visibility = "visibility"
        case windDirectionAvg = "windDirectionAvg"
        case windGustAvg = "windGustAvg"
        case windGustMax = "windGustMax"
        case windGustMin = "windGustMin"
        case windSpeedAvg = "windSpeedAvg"
        case windSpeedMax = "windSpeedMax"
        case windSpeedMin = "windSpeedMin"
    }
}

enum WeatherError: Error {
    case locationUnavailable
    case apiError(message: String)
    case decodingError
    case networkError
}

extension WeatherResponse {
    static func safeDecode(from data: Data) throws -> WeatherResponse {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            let json = try JSON(data: data)
            print("Decoding failed. Raw JSON:")
            print(json)
            throw error
        }
    }
    
    static func parse(from data: Data) throws -> WeatherResponse {
        let json = try JSON(data: data)
        
        guard json["success"].boolValue else {
            let message = json["message"].stringValue
            throw WeatherError.apiError(message: message)
        }
        
        return WeatherResponse(
            success: json["success"].boolValue,
            data: try parseWeatherData(json["data"])
        )
    }
    
    private static func parseWeatherData(_ json: JSON) throws -> WeatherData {
        WeatherData(
            dt: json["dt"].doubleValue,
            latitude: json["latitude"].doubleValue,
            longitude: json["longitude"].doubleValue,
            timezone: json["timezone"].stringValue,
            timezoneAbbreviation: json["timezone_abbreviation"].stringValue,
            timezoneOffset: json["timezone_offset"].intValue,
            units: json["units"].stringValue,
            currently: parseCurrentWeather(json["currently"]),
            hourly: parseHourlyForecast(json["hourly"]),
            daily: parseDailyForecast(json["daily"])
        )
    }
    
    private static func parseCurrentWeather(_ json: JSON) -> CurrentWeather {
        CurrentWeather(
            apparentTemperature: json["apparentTemperature"].doubleValue,
            cloudCover: json["cloudCover"].doubleValue,
            dewPoint: json["dewPoint"].doubleValue,
            humidity: json["humidity"].doubleValue,
            icon: json["icon"].stringValue,
            precipIntensity: json["precipIntensity"].doubleValue,
            pressure: json["pressure"].doubleValue,
            temperature: json["temperature"].doubleValue,
            uvIndex: json["uvIndex"].intValue,
            visibility: json["visibility"].intValue,
            windDirection: json["windDirection"].intValue,
            windGust: json["windGust"].doubleValue,
            windSpeed: json["windSpeed"].doubleValue
        )
    }
    
    private static func parseHourlyForecast(_ json: JSON) -> HourlyForecast {
        HourlyForecast(data: json["data"].arrayValue.map { parseHourlyData($0) })
    }
    
    private static func parseHourlyData(_ json: JSON) -> HourlyData {
        HourlyData(
            apparentTemperature: json["apparentTemperature"].double ?? json["apparentTemperatureAvg"].double,
            cloudCover: json["cloudCover"].double,
            dewPoint: json["dewPoint"].doubleValue,
            forecastStart: json["forecastStart"].doubleValue,
            humidity: json["humidity"].doubleValue,
            icon: json["icon"].stringValue,
            precipIntensity: json["precipIntensity"].double,
            precipProbability: json["precipProbability"].double,
            pressure: json["pressure"].double,
            temperature: json["temperature"].doubleValue,
            uvIndex: json["uvIndex"].intValue,
            visibility: json["visibility"].int,
            windDirection: json["windDirection"].int,
            windGust: json["windGust"].double,
            windSpeed: json["windSpeed"].double
        )
    }
    
    private static func parseDailyForecast(_ json: JSON) -> DailyForecast {
        DailyForecast(data: json["data"].arrayValue.map { parseDailyData($0) })
    }
    
    private static func parseDailyData(_ json: JSON) -> DailyData {
        DailyData(
            apparentTemperatureAvg: json["apparentTemperatureAvg"].double,
            apparentTemperatureMax: json["apparentTemperatureMax"].double,
            apparentTemperatureMin: json["apparentTemperatureMin"].double,
            cloudCover: json["cloudCover"].double,
            dewPointAvg: json["dewPointAvg"].double,
            dewPointMax: json["dewPointMax"].double,
            dewPointMin: json["dewPointMin"].double,
            forecastEnd: json["forecastEnd"].double,
            forecastStart: json["forecastStart"].double,
            humidity: json["humidity"].double,
            icon: json["icon"].string,
            moonPhase: json["moonPhase"].double,
            precipIntensity: json["precipIntensity"].double,
            precipProbability: json["precipProbability"].double,
            pressure: json["pressure"].double,
            sunriseTime: json["sunriseTime"].double,
            sunsetTime: json["sunsetTime"].double,
            temperatureAvg: json["temperatureAvg"].double,
            temperatureMax: json["temperatureMax"].double,
            temperatureMin: json["temperatureMin"].double,
            uvIndexMax: json["uvIndexMax"].int,
            visibility: json["visibility"].int,
            windDirectionAvg: json["windDirectionAvg"].int,
            windGustAvg: json["windGustAvg"].double,
            windGustMax: json["windGustMax"].double,
            windGustMin: json["windGustMin"].double,
            windSpeedAvg: json["windSpeedAvg"].double,
            windSpeedMax: json["windSpeedMax"].double,
            windSpeedMin: json["windSpeedMin"].double
        )
    }
}

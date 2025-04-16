//
//  WeatherIcons.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 15.04.2025.
//

import SwiftUI

enum WeatherIcon: String {
    case clear
    case partly_cloudy
    case mostly_cloudy
    case cloudy
    case light_rain
    case rain
    case heavy_rain
    case freezing_rain
    case thunderstorm
    case thunder_rain
    case light_snow
    case snow
    case heavy_snow
    case sleet
    case hail
    case windy
    case fog
    case mist
    case haze
    case smoke
    case dust
    case tornado
    case tropical_storm
    case hurricane
    case sandstorm
    case blizzard
    case unknown
    
    init(from iconString: String) {
        let formattedString = iconString
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
        
        self = WeatherIcon(rawValue: formattedString) ?? .unknown
    }
    
    var iconName: String {
        switch self {
        case .clear: return "sun.max"
        case .partly_cloudy: return "cloud.sun"
        case .mostly_cloudy: return "smoke"
        case .cloudy: return "cloud"
        case .light_rain: return "cloud.drizzle"
        case .rain: return "cloud.rain"
        case .heavy_rain: return "cloud.heavyrain"
        case .freezing_rain: return "cloud.sleet"
        case .thunderstorm: return "cloud.bolt"
        case .thunder_rain: return "cloud.bolt.rain"
        case .light_snow: return "cloud.snow"
        case .snow: return "snowflake"
        case .heavy_snow: return "wind.snow"
        case .sleet: return "cloud.sleet"
        case .hail: return "cloud.hail"
        case .windy: return "wind"
        case .fog: return "cloud.fog"
        case .mist: return "humidity"
        case .haze: return "sun.haze"
        case .smoke: return "smoke"
        case .dust: return "sun.dust"
        case .tornado: return "tornado"
        case .tropical_storm: return "tropicalstorm"
        case .hurricane: return "hurricane"
        case .sandstorm: return "cloud"
        case .blizzard: return "cloud.blizzard"
        case .unknown: return "questionmark"
        }
    }
}

struct WeatherIconView: View {
    let weatherType: WeatherIcon
    
    var body: some View {
        Image(systemName: weatherType.iconName)
            .font(.system(size: 40))
            .foregroundColor(.text)
    }
}

//
//  WeatherView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 15.04.2025.
//

import SwiftUI
import Charts

struct WeatherView: View {
    @StateObject var viewModel = WeatherViewModel()
    
    private let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    
    var gridData: [GridElement] {
        guard let weather = viewModel.weather else { return [] }
        
        return [
            GridElement(
                icon: "thermometer",
                title: "Ощущается",
                value: "\(weather.apparentTemperature.formatted())°C"
            ),
            GridElement(
                icon: "cloud",
                title: "Облачность",
                value: "\(Int(weather.cloudCover * 100))%"
            ),
            GridElement(
                icon: "drop",
                title: "Влажность",
                value: "\(Int(weather.humidity * 100))%"
            ),
            GridElement(
                icon: "wind",
                title: "Ветер",
                value: "\(weather.windSpeed.formatted()) м/с"
            ),
            GridElement(
                icon: "barometer",
                title: "Давление",
                value: "\(weather.pressure.formatted()) гПа"
            ),
            GridElement(
                icon: "umbrella",
                title: "Осадки",
                value: "\(weather.precipIntensity.formatted()) мм"
            ),
            GridElement(
                icon: "eye",
                title: "Видимость",
                value: "\(weather.visibility.formatted()) км"
            ),
            GridElement(
                icon: "sun.max",
                title: "УФ индекс",
                value: "\(weather.uvIndex)"
            )
        ]
    }
    
    var body: some View {
        LazyVStack(alignment: .center) {
            if let weather = viewModel.weather {
                if !viewModel.isExpanded {
                    compactView(weather: weather)
                } else {
                    expandedView
                }
            }else{
                errorView()
            }
        }
        .frame(width: UIScreen.screenWidth)
        .background(AppColors.bg1)
        .animation(.bouncy, value: viewModel.isExpanded)
        .shadow(radius: 10)
        .onTapGesture {
            if !viewModel.isExpanded{
                viewModel.toggle()
            }
        }
    }
    
    private func errorView() -> some View{
        CustomText(data: "Вот это дааа... Не смогли загрузить вашу погоду", font: Fonts.weatherDetails)
    }
    
    // MARK: - Compact View
    private func compactView(weather: CurrentWeather) -> some View {
        HStack {
            WeatherIconView(weatherType: WeatherIcon(from: weather.icon))
            CustomText(
                data: "\(weather.temperature.formatted())°C",
                font: Fonts.main
            )
            Spacer()
        }
        .padding(20)
        .frame(width: UIScreen.screenWidth, height: 50)
    }
    
    // MARK: - Expanded View
    private var expandedView: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    weatherGrid
                    temperatureChart
                }
                .padding()
            }
            
            collapseButton
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
    }
    
    // MARK: - Temperature Chart
    private var temperatureChart: some View {
        VStack(alignment: .leading) {
            Text("Температура за неделю")
                .font(.headline)
                .padding(.bottom, 8)
            
            if let dailyData = viewModel.dailyForecast?.data {
                let calendar = Calendar.current
                let currentDate = calendar.startOfDay(for: Date())
                
                let temperatures = dailyData.flatMap { [
                    $0.temperatureMax,
                    $0.temperatureMin,
                    $0.apparentTemperatureMax,
                    $0.apparentTemperatureMin
                ]}.compactMap { $0 }
                
                let minY = (temperatures.min() ?? 0) - 2
                let maxY = (temperatures.max() ?? 0) + 2
                let yStep = [1, 2, 5].first(where: { Double($0) <= (maxY - minY)/4 }) ?? 1
                
                Chart {
                    ForEach(Array(dailyData.enumerated()), id: \.offset) { index, day in
                        LineMark(
                            x: .value("День", index),
                            y: .value("Макс", day.temperatureMax ?? 0.0)
                        )
                        .foregroundStyle(.err)
                        .symbol(.circle)
                    }
                }
                .chartYScale(domain: minY...maxY)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .stride(by: 1)) { value in
                        AxisGridLine()
                        AxisTick()
                        if let temp = value.as(Double.self) {
                            AxisValueLabel {
                                Text("\(Int(temp))°C")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: 1)) { value in
                        AxisGridLine()
                        AxisTick()
                        if let dayIndex = value.as(Int.self) {
                            AxisValueLabel {
                                let dayNumber = calendar.component(.day, from: currentDate) + dayIndex
                                Text("\(dayNumber)")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
                .frame(height: 200)
                .padding()
            }
        }
        .onAppear {
            print(viewModel.dailyForecast?.data ?? [],
                 viewModel.dailyForecast?.data.count ?? 0)
        }
    }
    
    // MARK: - Weather Grid (остается без изменений)
    private var weatherGrid: some View {
        LazyVGrid(columns: gridItems, spacing: 20) {
            ForEach(gridData) { element in
                WeatherElement(
                    icon: element.icon,
                    title: element.title,
                    value: element.value
                )
            }
        }
    }
    
    // MARK: - Collapse Button (остается без изменений)
    private var collapseButton: some View {
        VStack {
            Spacer()
            Button(action: viewModel.toggle) {
                Image(systemName: "chevron.up.dotted.2")
                    .foregroundColor(.text)
                    .padding()
            }
            .padding(.bottom, 40)
        }
    }
}

struct GridElement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
}

struct WeatherElement: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.text)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.text)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(.fg1)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


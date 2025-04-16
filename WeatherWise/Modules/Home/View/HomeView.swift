//
//  HomeView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                MapView()
                    .zIndex(0)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else {
                    VStack{
                        WeatherView()
                            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                            .padding(.horizontal)
                            .cornerRadius(15, corners: .bottom)
                        Spacer()
                    }
                    .zIndex(2)
                }
                VStack {
                    Spacer()
                    SearchView()
                        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
                }
                .zIndex(1)
            }
            
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            viewModel.loadWeather()
        }
        .alert("Требуется доступ к локации",
               isPresented: $viewModel.showLocationAlert) {
            Button("Настройки") { viewModel.openSettings() }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Разрешите доступ к геолокации в настройках устройства")
        }
    }
}

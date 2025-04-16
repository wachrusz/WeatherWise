//
//  WeatherWiseApp.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import SwiftUI

@main
struct WeatherWiseApp: App {
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .colorScheme(.dark)
                .background(AppColors.bg)
        }
    }
    
    private func setupAppearance() {
        UITextField.appearance().tintColor = UIColor(AppColors.fg1)
        UITextView.appearance().tintColor = UIColor(AppColors.fg1)
        
        let selectionColor = UIColor(AppColors.fg).withAlphaComponent(0.3)
        
        let textField = UITextField.appearance()
        textField.tintColor = UIColor(AppColors.fg1)
        
        let textView = UITextView.appearance()
        textView.tintColor = UIColor(AppColors.fg1)
    }
}

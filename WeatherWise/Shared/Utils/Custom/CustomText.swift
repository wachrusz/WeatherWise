//
//  CustomText.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 15.04.2025.
//

import SwiftUI

struct CustomText: View{
    var data: String
    var font: Font
    
    var body: some View{
        Text(data)
            .font(font)
            .foregroundStyle(.text)
    }
}

enum Fonts{
    static let main = Font.system(size: 32).bold()
    static let weatherDetails = Font.system(size: 16)
}

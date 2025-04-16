//
//  CornerRadius.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 15.04.2025.
//

import SwiftUI

struct CornerOptions: OptionSet {
    let rawValue: Int
    
    static let topLeft = CornerOptions(rawValue: 1 << 0)
    static let topRight = CornerOptions(rawValue: 1 << 1)
    static let bottomLeft = CornerOptions(rawValue: 1 << 2)
    static let bottomRight = CornerOptions(rawValue: 1 << 3)
    
    static let top: CornerOptions = [.topLeft, .topRight]
    static let bottom: CornerOptions = [.bottomLeft, .bottomRight]
    static let left: CornerOptions = [.topLeft, .bottomLeft]
    static let right: CornerOptions = [.topRight, .bottomRight]
    static let all: CornerOptions = [.top, .bottom, .left, .right]
    static let none: CornerOptions = []
}

struct RoundedCornersShape: Shape {
    var radius: CGFloat
    var corners: CornerOptions
    
    private func shouldRound(_ corner: CornerOptions) -> Bool {
        !corners.intersection(corner).isEmpty
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        
        if shouldRound(.topLeft) {
            path.move(to: CGPoint(x: minX + radius, y: minY))
            path.addArc(center: CGPoint(x: minX + radius, y: minY + radius),
                        radius: radius,
                        startAngle: .degrees(-180),
                        endAngle: .degrees(-90),
                        clockwise: false)
        } else {
            path.move(to: CGPoint(x: minX, y: minY))
        }
        
        if shouldRound(.topRight) {
            path.addLine(to: CGPoint(x: maxX - radius, y: minY))
            path.addArc(center: CGPoint(x: maxX - radius, y: minY + radius),
                        radius: radius,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(0),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: maxX, y: minY))
        }
        
        if shouldRound(.bottomRight) {
            path.addLine(to: CGPoint(x: maxX, y: maxY - radius))
            path.addArc(center: CGPoint(x: maxX - radius, y: maxY - radius),
                        radius: radius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(90),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: maxX, y: maxY))
        }
        
        if shouldRound(.bottomLeft) {
            path.addLine(to: CGPoint(x: minX + radius, y: maxY))
            path.addArc(center: CGPoint(x: minX + radius, y: maxY - radius),
                        radius: radius,
                        startAngle: .degrees(90),
                        endAngle: .degrees(180),
                        clockwise: false)
        } else {
            path.addLine(to: CGPoint(x: minX, y: maxY))
        }
        
        path.closeSubpath()
        return path
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: CornerOptions) -> some View {
        clipShape(RoundedCornersShape(radius: radius, corners: corners))
    }
}

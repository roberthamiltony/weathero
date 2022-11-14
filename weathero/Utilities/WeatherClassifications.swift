//
//  WeatherClassifications.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation

enum WeatherClassifications {
    static let lightRainRange: Range<Float> = (0..<2.5)
    static let moderateRain: Range<Float> = (2.5..<7.5)
    static let heavyRain: Range<Float> = (7.5..<50.0)
    
    /// A realistic range for weather in the UK. If precipiration is above this, some other dialog should be shown to highlight this.
    static let rainChartScale: ClosedRange<Float> = (0...15.0)
    
    static let cold = -10.0
    static let hot = 35.0
}

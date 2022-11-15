//
//  DayWeatherSummaryModelTests.swift
//  weatheroTests
//
//  Created by Robert Hamilton on 15/11/2022.
//

import Foundation
import XCTest
@testable import weathero

class DayWeatherSummaryModelTests: XCTestCase {
    func testTemperatureRangeIsCorrect() {
        let firstModel = DayWeatherSummaryModel(precipitationType: .clear, minTemperature: -100.0, maxTemperature: 0.0, forecastStart: .now)
        let secondModel = DayWeatherSummaryModel(precipitationType: .clear, minTemperature: 0, maxTemperature: 100.0, forecastStart: .now)
        let range = [firstModel, secondModel].temperatureRange
        XCTAssertEqual(-100, range?.lowerBound)
        XCTAssertEqual(100, range?.upperBound)
    }
}

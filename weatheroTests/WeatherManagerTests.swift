//
//  WeatherManagerTests.swift
//  weatheroTests
//
//  Created by Robert Hamilton on 14/11/2022.
//

import XCTest
import Combine
import CoreLocation
@testable import weathero

class WeatherManagerTests: XCTestCase {
    func testWeatherManagerPublishesNextHourResult() {
        let weatherManager = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        weatherManager.apiClient = MockWeatherAPIClient()
        var cancellable: AnyCancellable
        let expectation = XCTestExpectation()
        cancellable = weatherManager.$nextHourData
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    expectation.fulfill()
                default:
                    break
                }
            })
        weatherManager.getData(dataSets: [.forecastNextHour])
        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
    
    func testWeatherManagerPublishesNextDaysResult() {
        let weatherManager = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        weatherManager.apiClient = MockWeatherAPIClient()
        var cancellable: AnyCancellable
        let expectation = XCTestExpectation()
        cancellable = weatherManager.$nextDaysData
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    expectation.fulfill()
                default:
                    break
                }
            })
        weatherManager.getData(dataSets: [.forecastDaily])
        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
    
    func testWeatherManagerPublishesErrorIfDailyForcastIsMissing() {
        let weatherManager = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        let mockClient = MockWeatherAPIClient()
        mockClient.forceExcludeDailyForecastData = true
        weatherManager.apiClient = mockClient
        var cancellable: AnyCancellable
        let expectation = XCTestExpectation()
        cancellable = weatherManager.$nextDaysData
            .sink(receiveValue: { result in
                switch result {
                case .failure:
                    expectation.fulfill()
                default:
                    break
                }
            })
        weatherManager.getData(dataSets: [.forecastDaily])
        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
    
    func testWeatherManagerPublishesErrorIfNextHourIsMissing() {
        let weatherManager = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        let mockClient = MockWeatherAPIClient()
        mockClient.forceExcludeNextHourData = true
        weatherManager.apiClient = mockClient
        var cancellable: AnyCancellable
        let expectation = XCTestExpectation()
        cancellable = weatherManager.$nextHourData
            .sink(receiveValue: { result in
                switch result {
                case .failure:
                    expectation.fulfill()
                default:
                    break
                }
            })
        weatherManager.getData(dataSets: [.forecastNextHour])
        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
    
    func testChangingLocationClearsData() {
        let weatherManager = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        let mockClient = MockWeatherAPIClient()
        weatherManager.apiClient = mockClient
        let hourExpectation = XCTestExpectation()
        let dailyExpectation = XCTestExpectation()
        let hourlyCancellable = weatherManager.$nextHourData
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    hourExpectation.fulfill()
                default:
                    break
                }
            })
        let dailyCancellable = weatherManager.$nextDaysData
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    dailyExpectation.fulfill()
                default:
                    break
                }
            })
        weatherManager.getData(dataSets: [.forecastNextHour, .forecastDaily])
        wait(for: [hourExpectation, dailyExpectation], timeout: 0.5)
        hourlyCancellable.cancel()
        dailyCancellable.cancel()
        weatherManager.currentLocation = CLLocation(latitude: 1.0, longitude: 1.0)
        XCTAssertNil(weatherManager.nextDaysData)
        XCTAssertNil(weatherManager.nextHourData)
    }
}

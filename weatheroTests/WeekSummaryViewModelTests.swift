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

class WeekSummaryViewModelTests: XCTestCase {
    func testWeatherManagerPublishesNextHourResult() {
        let viewModel = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        viewModel.apiClient = MockWeatherAPIClient()
        var cancellable: AnyCancellable
        let expectation = XCTestExpectation()
        cancellable = viewModel.$nextHourData
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    expectation.fulfill()
                default:
                    break
                }
            })
        viewModel.getData(dataSets: [.forecastNextHour])
        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
    
    func testWeatherManagerPublishesNextDaysResult() {
        let viewModel = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        viewModel.apiClient = MockWeatherAPIClient()
        var cancellable: AnyCancellable
        let expectation = XCTestExpectation()
        cancellable = viewModel.$nextDaysData
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    expectation.fulfill()
                default:
                    break
                }
            })
        viewModel.getData(dataSets: [.forecastDaily])
        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
    
    func testWeatherManagerPublishesErrorIfDailyForcastIsMissing() {
        let viewModel = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        let mockClient = MockWeatherAPIClient()
        mockClient.forceExcludeDailyForecastData = true
        viewModel.apiClient = mockClient
        var cancellable: AnyCancellable
        let expectation = XCTestExpectation()
        cancellable = viewModel.$nextDaysData
            .sink(receiveValue: { result in
                switch result {
                case .failure:
                    expectation.fulfill()
                default:
                    break
                }
            })
        viewModel.getData(dataSets: [.forecastDaily])
        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
    
    func testWeatherManagerPublishesErrorIfNextHourIsMissing() {
        let viewModel = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        let mockClient = MockWeatherAPIClient()
        mockClient.forceExcludeNextHourData = true
        viewModel.apiClient = mockClient
        var cancellable: AnyCancellable
        let expectation = XCTestExpectation()
        cancellable = viewModel.$nextHourData
            .sink(receiveValue: { result in
                switch result {
                case .failure:
                    expectation.fulfill()
                default:
                    break
                }
            })
        viewModel.getData(dataSets: [.forecastNextHour])
        wait(for: [expectation], timeout: 0.5)
        cancellable.cancel()
    }
    
    func testChangingLocationClearsData() {
        let viewModel = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
        let mockClient = MockWeatherAPIClient()
        viewModel.apiClient = mockClient
        let hourExpectation = XCTestExpectation()
        let dailyExpectation = XCTestExpectation()
        let hourlyCancellable = viewModel.$nextHourData
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    hourExpectation.fulfill()
                default:
                    break
                }
            })
        let dailyCancellable = viewModel.$nextDaysData
            .sink(receiveValue: { result in
                switch result {
                case .success:
                    dailyExpectation.fulfill()
                default:
                    break
                }
            })
        viewModel.getData(dataSets: [.forecastNextHour, .forecastDaily])
        wait(for: [hourExpectation, dailyExpectation], timeout: 0.5)
        hourlyCancellable.cancel()
        dailyCancellable.cancel()
        viewModel.currentLocation = CLLocation(latitude: 1.0, longitude: 1.0)
        XCTAssertNil(viewModel.nextDaysData)
        XCTAssertNil(viewModel.nextHourData)
    }
}

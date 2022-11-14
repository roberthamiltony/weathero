//
//  WeatherManager.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import Combine
import CoreLocation

class WeatherManager {
    @Published private(set) var nextHourData: Result<[MinutePrecipitationData], Error>?
    @Published private(set) var nextDaysData: Result<[DailyForecast.DayWeatherCondition], Error>?
    
    @Published var currentLocation: CLLocation {
        didSet {
            nextHourData = nil
            nextDaysData = nil
            fetchingDataFuture?.cancel()
            fetchingDataFuture = nil
        }
    }
    let forecastStart: Date?
    
    /// Initializes a weather manager instance
    /// - Parameters:
    ///   - location: The location to get weather for
    ///   - forecastStart: The time to get forecasts from. Leave as nil to get the current weather.
    init(location: CLLocation, forecastStart: Date? = nil) {
        self.currentLocation = location
        self.forecastStart = forecastStart
    }
    
    private var fetchingDataFuture: AnyCancellable?
    func getData(dataSets: [WeatherRequest.DataSet]) {
        guard fetchingDataFuture == nil else { return }
        let request = WeatherRequest(
            latitude: Float(currentLocation.coordinate.latitude),
            longitude: Float(currentLocation.coordinate.longitude),
            dataSets: dataSets,
            dailyStart: forecastStart,
            hourlyStart: forecastStart
        )
        fetchingDataFuture = WeatherAPIClient()
            .perform(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.fetchingDataFuture?.cancel()
                self?.fetchingDataFuture = nil
                switch error {
                case .failure(let error):
                    if dataSets.contains(.forecastNextHour) {
                        self?.nextHourData = .failure(error)
                    }
                    if dataSets.contains(.forecastDaily) {
                        self?.nextDaysData = .failure(error)
                    }
                default:
                    break
                }
            } receiveValue: { [weak self] weatherResponse in
                guard let self else { return }
                if dataSets.contains(.forecastNextHour) {
                    if let nextHourResponse = weatherResponse.forecastNextHour {
                       self.nextHourData = .success(self.hourDataReducer(hourData: nextHourResponse))
                   } else {
                       self.nextHourData = .failure(WeatherManagerError.dataNotFound)
                   }
                }
                if dataSets.contains(.forecastDaily) {
                   if let nextDaysResponse = weatherResponse.forecastDaily {
                       self.nextDaysData = .success(nextDaysResponse.days)
                   } else {
                       self.nextDaysData = .failure(WeatherManagerError.dataNotFound)
                   }
                }
            }
    }
    
    private func hourDataReducer(hourData: NextHourForecast.NextHourForecastData) -> [MinutePrecipitationData] {
        hourData.minutes
            .sorted { $0.startTime < $1.startTime }
            .enumerated()
            .map { MinutePrecipitationData(precipitation: $0.element.precipitationIntensity, offset: $0.offset) }
    }
    
    enum WeatherManagerError: Error {
        case dataNotFound
    }
}

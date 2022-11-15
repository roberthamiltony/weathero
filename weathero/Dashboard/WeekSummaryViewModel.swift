//
//  WeatherManager.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import Combine
import CoreLocation

class WeekSummaryViewModel {
    
    /// The results from fetching the next hour data. Nil corresponds to no data or fetching data. Use `getData` with `.forecastNextHour` to request this field.
    @Published private(set) var nextHourData: Result<[MinutePrecipitationData], Error>?
    
    /// The results from fetching the next days data. Nil corresponds to no data or fetching data. Use `getData` with `.forecastDaily` to request this field.
    @Published private(set) var nextDaysData: Result<[DayWeatherSummaryModel], Error>? {
        didSet {
            switch nextDaysData {
            case .success(let days):
                daysTemperatureRange = days.temperatureRange
            default:
                daysTemperatureRange = nil
            }
        }
    }
    
    /// A range encompassing all temperature values from the days data
    private(set) var daysTemperatureRange: ClosedRange<Float>?
    
    /// The location this view model is contextual for. Updating this value will invalidate any modles and requests.
    @Published var currentLocation: CLLocation {
        willSet { invalidateLocation() }
        didSet { bindLocation() }
    }
    
    /// A readable string for the location.
    @Published private(set) var currentLocationName: String?
    
    /// The date this view model will fetch forecasts from.
    let forecastStart: Date?
    
    /// The API client the view model will use to fetch weather models.
    var apiClient: APIClient = WeatherAPIClient()
    
    /// Initializes a weather manager instance
    /// - Parameters:
    ///   - location: The location to get weather for
    ///   - forecastStart: The time to get forecasts from. Leave as nil to get the current weather.
    init(location: CLLocation, forecastStart: Date? = nil) {
        self.currentLocation = location
        self.forecastStart = forecastStart
        bindLocation()
    }
    
    private func bindLocation() {
        LocationHelpers.calculateLocationName(location: currentLocation) { [weak self] in self?.currentLocationName = $0 }
    }
    
    private func invalidateLocation() {
        nextHourData = nil
        nextDaysData = nil
        fetchingDataFuture?.cancel()
        fetchingDataFuture = nil
    }
    
    private var fetchingDataFuture: AnyCancellable?
    /// Fetches weather models for the given data sets. Results are published through `nextDaysData` and `nextHourData`
    func getData(dataSets: [WeatherRequest.DataSet]) {
        guard fetchingDataFuture == nil else { return }
        let request = WeatherRequest(
            latitude: Float(currentLocation.coordinate.latitude),
            longitude: Float(currentLocation.coordinate.longitude),
            dataSets: dataSets,
            dailyStart: forecastStart,
            hourlyStart: forecastStart
        )
        fetchingDataFuture = apiClient
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
                       self.nextDaysData = .success(self.daysDataReducer(daysData: nextDaysResponse.days))
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
    
    private func daysDataReducer(daysData: [DailyForecast.DayWeatherCondition]) -> [DayWeatherSummaryModel] {
        daysData
            .sorted { $0.forecastStart < $1.forecastStart}
            .map {
                DayWeatherSummaryModel(
                    precipitationType: $0.precipitationType,
                    minTemperature: $0.temperatureMin,
                    maxTemperature: $0.temperatureMax,
                    forecastStart: $0.forecastStart
                )
            }
    }
    
    enum WeatherManagerError: Error {
        case dataNotFound
    }
}

private extension [DayWeatherSummaryModel] {
    /// Returns the range of temperature values provided by the day models.
    var temperatureRange: ClosedRange<Float>? {
        guard
            let minimum = self.min(by: {$0.minTemperature < $1.minTemperature})?.minTemperature,
            let maximum = self.max(by: {$0.maxTemperature < $1.maxTemperature})?.maxTemperature,
            maximum > minimum
        else {
            return nil
        }
        return (minimum...maximum)
    }
}

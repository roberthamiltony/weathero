//
//  MockWeatherAPIClient.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation

class MockWeatherAPIClient: APIClient {
    var mockRainRange: Range<Float> = WeatherClassifications.moderateRain
    var minTemperatureRange: Range<Float> = (-10.0..<0)
    var maxTemperatureRange: Range<Float> = (0.1..<10.0)
    
    var forceExcludeNextHourData = false
    var forceExcludeDailyForecastData = false
    
    func perform<T>(request: T, completion: @escaping ((Result<T.Response, Error>) -> Void)) where T : APIRequest {
        guard let weatherRequest = request as? WeatherRequest else {
            completion(.failure(MockErrors.mockError))
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        var returnModel = Weather()
        if weatherRequest.dataSets.contains(.forecastDaily),
           !forceExcludeDailyForecastData,
           let mockDataURL = Bundle.main.url(forResource: "MockDailyResponse", withExtension: "json"),
           let mockData = try? Data(contentsOf: mockDataURL),
           var forecastDaily = try? decoder.decode(DailyForecast.DailyForecastData.self, from: mockData)
        {
            forecastDaily.days = forecastDaily.days.map { day in
                let temperatureMin = Float.random(in: minTemperatureRange)
                let temperatureMax = Float.random(in: maxTemperatureRange)
                return day.copy(minTemperature: temperatureMin, maxTemeprature: temperatureMax, precipitationType: day.precipitationType)
            }
            returnModel.forecastDaily = forecastDaily
        }
        if weatherRequest.dataSets.contains(.forecastNextHour),
           !forceExcludeNextHourData,
           let mockDataURL = Bundle.main.url(forResource: "MockNextHourResponse", withExtension: "json"),
           let mockData = try? Data(contentsOf: mockDataURL),
           var nextHour = try? decoder.decode(NextHourForecast.NextHourForecastData.self, from: mockData)
        {
            nextHour.minutes = nextHour.minutes.map { .init(precipitationChance: 1.0, precipitationIntensity: Float.random(in: mockRainRange), startTime: $0.startTime) }
            returnModel.forecastNextHour = nextHour
        }
        if let response = returnModel as? T.Response {
            completion(.success(response))
        } else {
            completion(.failure(MockErrors.mockError))
        }
    }
    
    enum MockErrors: Error {
        case mockError
    }
}

extension DailyForecast.DayWeatherCondition {
    func copy(minTemperature: Float, maxTemeprature: Float, precipitationType: PrecipitationType) -> Self {
        .init(conditionCode: conditionCode, forecastEnd: forecastEnd, forecastStart: forecastStart, maxUvIndex: maxUvIndex, moonPhase: moonPhase, precipitationAmount: precipitationAmount, precipitationChance: precipitationChance, precipitationType: precipitationType, snowfallAmount: snowfallAmount, temperatureMax: maxTemeprature, temperatureMin: minTemperature)
    }
}

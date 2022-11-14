//
//  WeatherRequest.swift
//  weathero
//
//  Created by Robert Hamilton on 13/11/2022.
//

import Foundation

struct WeatherRequest: APIRequest {
    typealias Response = Weather
    
    var resource: String { "/api/v1/weather/en/\(latitude)/\(longitude)" }
    var queries: [URLQueryItem] {
        [
            URLQueryItem(name: "country", value: countryCode),
            URLQueryItem(name: "dataSets", value: dataSets.map { $0.rawValue }.joined(separator: ",")),
            URLQueryItem(name: "timezone", value: timezone),
            URLQueryItem(name: "dailyStart", value: string(from: dailyStart)),
            URLQueryItem(name: "hourlyStart", value: string(from: hourlyStart))
        ]
    }
    
    var latitude: Float
    var longitude: Float
    
    var countryCode: String = "GB"
    var dataSets: [DataSet]
    var timezone: String = "GMT"
    var currentAsOf: Date?  // defaults to now if not present
    var dailyEnd: Date?  // defaults to 10 days from now
    var dailyStart: Date?  // defaults to today
    var hourlyEnd: Date?
    var hourlyStart: Date?
    
    private func string(from date: Date?) -> String? {
        if let date {
            return ISO8601DateFormatter().string(from: date)
        }
        return nil
    }
    
    enum DataSet: String {
        case currentWeather, forecastDaily, forecastHourly, forecastNextHour, weatherAlerts
    }
}


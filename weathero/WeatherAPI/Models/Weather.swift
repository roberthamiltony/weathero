//
//  Weather.swift
//  weathero
//
//  Created by Robert Hamilton on 07/11/2022.
//

import Foundation

struct Weather: Codable {
    var currentWeather: CurrentWeather.CurrentWeatherData?
    var forecastDaily: DailyForecast.DailyForecastData?
    var forecastHourly: HourlyForecast.HourlyForecastData?
    var forecastNextHour: NextHourForecast.NextHourForecastData?
    var weatherAlerts: WeatherAlertCollection.WeatherAlertCollectionData?
}

struct CurrentWeather: Codable {
    struct CurrentWeatherData: Codable {
        var asOf: Date
        var cloudCover: Float
        var conditionCode: String // enum
        var daylight: Bool
        var humidity: Float
        var precipitationIntensity: Float
        var pressure: Float
        var pressureTrend: PressureTrend
        var temperature: Float // celsius
        var temperatureApparant: Float // celsius
        var temperatureDewPoint: Float // celsius
        var uvIndex: Int
        var visibility: Float
        var windDirection: Int
        var windGust: Float
        var windSpeed: Float
    }
}

struct DailyForecast: Codable {
    struct DailyForecastData: Codable {
        var days: [DayWeatherCondition]
    }
    
    struct DayWeatherCondition: Codable {
        var conditionCode: String // enum
        var daytimeForecast: DayPartForecast?
        var forecastEnd: Date
        var forecastStart: Date
        var maxUvIndex: Int
        var moonPhase: MoonPhase
        var moonrise: Date?
        var moonset: Date?
        var overnightForecast: DayPartForecast?
        var precipitationAmount: Float
        var precipitationChance: Float
        var precipitationType: PrecipitationType
        var snowfallAmount: Float
        var solarMidnight: Date?
        var solarNoon: Date?
        var sunrise: Date?
        var sunriseAstronomical: Date?
        var sunriseCivil: Date?
        var sunriseNautical: Date?
        var temperatureMax: Float
        var temperatureMin: Float
    }
    
    struct DayPartForecast: Codable {
        var cloudCover: Float
        var conditionCode: String
        var forecastEnd: Date
        var forecastStart: Date
        var humidity: Float
        var precipitationAmount: Float
        var precipitationChance: Float
        var precipitationType: PrecipitationType
        var snowfallAmount: Float
        var windDirection: Int
        var windSpeed: Float
    }
}

struct HourlyForecast: Codable {
    struct HourlyForecastData: Codable {
        var hours: HourWeatherConditions
    }
    
    struct HourWeatherConditions: Codable {
        var cloudCover: Float
        var conditionCode: String
        var daylight: Bool?
        var forecastStart: Date
        var humidity: Float
        var precipitationChance: Float
        var precipitationType: PrecipitationType
        var pressure: Float
        var pressureTrend: PressureTrend?
        var snowfallIntensity: Float?
        var temperature: Float
        var temperatureApparent: Float
        var temperatureDewPoint: Float?
        var uvIndex: Int
        var visibility: Float
        var windDirection: Int?
        var windGust: Float?
        var windSpeed: Float
        var precipitationAmount: Float?
    }
}

struct NextHourForecast: Codable {
    struct NextHourForecastData: Codable {
        var forecastEnd: Date?
        var forecastStart: Date?
        var minutes: [ForecastMinute]
        var summary: [ForecastPeriodSummary]
    }
    
    struct ForecastMinute: Codable {
        var precipitationChance: Float
        var precipitationIntensity: Float
        var startTime: Date
    }
    
    struct ForecastPeriodSummary: Codable {
        var condition: PrecipitationType
        var endTime: Date?
        var precipitationChance: Float
        var precipitationIntensity: Float
        var startTime: Date
    }
}

struct WeatherAlertCollection {
    struct WeatherAlertCollectionData: Codable {
        var alerts: [WeatherAlertSummary]
    }
    
    struct WeatherAlertSummary: Codable {
        var areaId: String?
        var areaName: String?
        var certainty: Certainty
        var countryCode: String
        var description: String
        var detailsUrl: URL?
        var effectiveTime: Date
        var eventEndTime: Date?
        var eventOnsetTime: Date?
        var expireTime: Date
        var id: UUID
        var issuedTime: Date
        var responses: [ResponseType]
        var severity: Severity
        var source: String
        var urgency: Urgency?
    }
    
    enum Certainty: String, Codable {
        case observed, likely, possible, unlikely, unknown
    }
    
    enum ResponseType: String, Codable {
        case shelter, evacuate, prepare, execute, avoid, monitor, assess, allClear, none
    }
    
    enum Severity: String, Codable {
        case extreme, severe, moderate, minor, unknown
    }
    
    enum Urgency: String, Codable {
        case immediate, expected, future, past, unknown
    }
}

enum MoonPhase: String, Codable {
    case new, waxingCrescent, firstQuarter, full, waxingGibbous, waningGibbous, thirdQuarter, waningCrescent
}

enum PressureTrend: String, Codable {
    case rising, falling, steady
}

enum PrecipitationType: String, Codable {
    case rain, clear, precipitation, snow, sleet, hail, mixed
}

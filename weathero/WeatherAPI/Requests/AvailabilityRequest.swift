//
//  AvailabilityRequest.swift
//  weathero
//
//  Created by Robert Hamilton on 10/11/2022.
//

import Foundation

struct AvailabilityRequest: APIRequest {
    typealias Response = AvailabilityResponse
    
    var resource: String { "/api/v1/availability/\(latitude)/\(longitude)" }
    var queries: [URLQueryItem] {
        [
            URLQueryItem(name: "country", value: countryCode),
        ]
    }
    
    var latitude: Float
    var longitude: Float
    var countryCode: String
}

struct AvailabilityResponse: Codable {
    
}

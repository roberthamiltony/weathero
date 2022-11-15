//
//  LocationHelpers.swift
//  weathero
//
//  Created by Robert Hamilton on 15/11/2022.
//

import Foundation
import CoreLocation

enum LocationHelpers {
    /// Calls the completion handler with a readable name for the given location
    static func calculateLocationName(location: CLLocation, completion: @escaping ((String?) -> Void)) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else {
                completion("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                return
            }
            completion(placemark.name ?? "\(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
}

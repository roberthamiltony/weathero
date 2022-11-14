//
//  LocationCoordinator.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import CoreLocation

class LocationCoordinator: NavigationCoordinator {
    var weatherManager: WeatherManager?
    
    override func start() {
        let locationPicker = LocationPickerViewController()
        locationPicker.proposedLocation = weatherManager?.currentLocation
        locationPicker.coordinator = self
        navigationController.pushViewController(locationPicker, animated: true)
    }
}

extension LocationCoordinator: LocationPickerCoordinator {
    func picker(_ viewController: LocationPickerViewController, picked: CLLocation) {
        weatherManager?.currentLocation = picked
        finish(animated: true)
    }
}

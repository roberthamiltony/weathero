//
//  AppCoordinator.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import UIKit
import CoreLocation

class AppCoordinator: NavigationCoordinator {
    override init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        navigationController.isNavigationBarHidden = true
    }
    
    override func start() {
        let summaryController = WeekSummaryViewController()
        summaryController.coordinator = self
        pushViewController(summaryController, animated: false)
    }
}

extension AppCoordinator: WeekSummaryCoordinator {
    func weekSummaryDidRequestNewLocation(_ viewController: WeekSummaryViewController) {
        let locationCoordinator = LocationCoordinator(navigationController: UINavigationController())
        locationCoordinator.weatherManager = viewController.weatherManager
        addChild(locationCoordinator)
        coordinatingViewController.present(locationCoordinator.coordinatingViewController, animated: true)
        locationCoordinator.start()
    }
}

class LocationCoordinator: NavigationCoordinator {
    var weatherManager: WeatherManager?
    
//    override init(navigationController: UINavigationController) {
//        super.init(navigationController: navigationController)
//        navigationController.isNavigationBarHidden = true
//    }
    
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

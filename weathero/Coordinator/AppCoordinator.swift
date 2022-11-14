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
        locationCoordinator.start()
        coordinatingViewController.present(locationCoordinator.coordinatingViewController, animated: true)
    }
}

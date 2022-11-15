//
//  WeeklySummaryTests.swift
//  weatheroUITests
//
//  Created by Robert Hamilton on 15/11/2022.
//

import Foundation
import XCTest

final class WeeklySummaryFlowTests: XCTestCase {
    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testExample() throws {
        // enter the location flow
        app.buttons[WeekSummaryIdentifiers.requestLocationButton.rawValue].await().tap()
        // leave the location flow
        app.buttons[LocationIdentifiers.confirmButton.rawValue].await(timeout: 1.0).tap()
        app.buttons[WeekSummaryIdentifiers.requestLocationButton.rawValue].await()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

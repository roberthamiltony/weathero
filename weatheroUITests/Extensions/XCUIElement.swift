//
//  XCUIElement.swift
//  weatheroUITests
//
//  Created by Robert Hamilton on 15/11/2022.
//

import Foundation
import XCTest

extension XCUIElement {
    
    @discardableResult func await(timeout: TimeInterval = 0.5) -> XCUIElement {
        guard waitForExistence(timeout: timeout) else {
            XCTFail("Could not find element: \(self.debugDescription)")
            return self
        }
        return self
    }
}

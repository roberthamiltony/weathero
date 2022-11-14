//
//  Color.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    static func fromHex(red: Double, green: Double, blue: Double) -> Color {
        .init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
    }
}

extension UIColor {
    static func fromHex(red: Double, green: Double, blue: Double) -> UIColor {
        .init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
}

//
//  Array.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import Combine

extension Array {
    func safeGet(_ index: Int) -> Element? {
        (0..<count).contains(index) ? self[index] : nil
    }
}

extension Array where Element: AnyCancellable {
    mutating func cancelAndRemoveAll() {
        self.forEach { $0.cancel() }
        self = []
    }
}

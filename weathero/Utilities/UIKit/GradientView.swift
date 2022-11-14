//
//  GradientView.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import UIKit

/// A view to display a gradient.
class GradientView: UIView {
    let gradient: CAGradientLayer
    init(gradient: CAGradientLayer) {
        self.gradient = gradient
        super.init(frame: .zero)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        layer.addSublayer(gradient)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.actions = ["position": NSNull(), "bounds": NSNull()]
        gradient.frame = bounds
    }
}

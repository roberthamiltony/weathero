//
//  WeeklySummaryTitleView.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import UIKit

class WeeklySummaryTitleView: UIView {
    var title: String? {
        didSet {
            UIView.animate(withDuration: 0.25) { [titleLabel, title] in
                titleLabel.text = title
            }
        }
    }
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26.0, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

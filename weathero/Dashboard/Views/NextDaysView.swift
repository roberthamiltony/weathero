//
//  NextDaysView.swift
//  weathero
//
//  Created by Robert Hamilton on 13/11/2022.
//

import Foundation
import SwiftUI
import UIKit

class NextDaysView: UIView {
    let collectionView: UICollectionView = {
        let layout = DynamicHeightFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collectionView = IntrinsicResizingCollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: Cells
class DayWeatherCollectionViewCell: UICollectionViewCell {
    static let identifier = "com.rob.weatheropo.DayWeatherCollectionViewCell"
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    let precipirationTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let temperatureRangeView = TemperatureRangeView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [dateLabel, precipirationTypeImageView, temperatureRangeView].forEach { contentView.addSubview($0) }
    }
    
    private func setupConstraints() {
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.left.equalToSuperview().inset(8)
        }
        precipirationTypeImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalTo(dateLabel)
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(4)
        }
        temperatureRangeView.snp.makeConstraints { make in
            make.left.equalTo(precipirationTypeImageView.snp.right).offset(8)
            make.right.equalToSuperview().inset(4)
            make.centerY.equalTo(precipirationTypeImageView)
            make.height.equalTo(32)
        }
    }
    
    func bind(day: DailyForecast.DayWeatherCondition, temperatureRange: ClosedRange<Float>?) {
        var image: UIImage?
        switch day.precipitationType {
        case .rain, .precipitation:
            if WeatherClassifications.lightRainRange.contains(day.precipitationAmount) {
                image = UIImage(systemName: "cloud.rain")
            } else {
                image = UIImage(systemName: "cloud.heavyrain")
            }
        case .clear:
            image = UIImage(systemName: "sun.max")
        case .snow:
            if WeatherClassifications.lightRainRange.contains(day.precipitationAmount) {
                image = UIImage(systemName: "snowflake")
            } else {
                image = UIImage(systemName: "cloud.snow")
            }
        case .sleet:
            image = UIImage(systemName: "cloud.sleet")
        case .hail:
            image = UIImage(systemName: "cloud.hail")
        case .mixed:
            image = UIImage(systemName: "questionmark")
        }
        precipirationTypeImageView.image = image
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: day.forecastStart)
        dateLabel.text = dayInWeek
        
        if let range = temperatureRange {
            temperatureRangeView.bind(range: range, min: day.temperatureMin, max: day.temperatureMax)
            temperatureRangeView.isHidden = false
        } else {
            temperatureRangeView.isHidden = true
        }
    }
}

class TemperatureRangeView: UIView {
    private let hotColour = UIColor.fromHex(red: 252.0, green: 94.0, blue: 3.0)
    private let coldColour = UIColor.fromHex(red: 143.0, green: 206.0, blue: 227.0)
    let backgroundGradient: GradientView = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        let view = GradientView(gradient: layer)
        view.clipsToBounds = true
        return view
    }()
    let rangeBubble: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundGradient)
        backgroundGradient.snp.makeConstraints { $0.edges.equalToSuperview() }
        backgroundGradient.mask = rangeBubble
        rangeBubble.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rangeBubble.layer.cornerRadius = min(rangeBubble.frame.height, rangeBubble.frame.width) / 2
    }
    
    func bind(range: ClosedRange<Float>, min: Float, max: Float) {
        layoutIfNeeded()
        let width = frame.width
        let rangeWidth = range.upperBound - range.lowerBound
        let minimumOffset = CGFloat((min - range.lowerBound) / rangeWidth) * width
        let maximumOffset = CGFloat((max - range.lowerBound) / rangeWidth) * width
        rangeBubble.frame = CGRect(x: minimumOffset, y: 0, width: maximumOffset - minimumOffset, height: frame.height)
        backgroundGradient.gradient.colors = [coldColour.cgColor, UIColor.white.cgColor, hotColour.cgColor]
        let coldLocation = (Float(WeatherClassifications.cold) - range.lowerBound) / rangeWidth
        let hotLocation = (Float(WeatherClassifications.hot) - range.lowerBound) / rangeWidth
        let midLocation = (hotLocation + coldLocation) / 2.0
        backgroundGradient.gradient.locations = [
            NSNumber(value: coldLocation),
            NSNumber(value: midLocation),
            NSNumber(value: hotLocation)
        ]
        setNeedsLayout()
        layoutIfNeeded()
    }
}

class DayWeatherLoadingCollectionViewCell: UICollectionViewCell {
    static let identifier = "com.rob.weatheropo.DayWeatherLoadingCollectionViewCell"
    let activityInditcator = UIActivityIndicatorView(style: .large)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(activityInditcator)
    }
    
    private func setupConstraints() {
        activityInditcator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class DayWeatherFailedCollectionViewCell: UICollectionViewCell {
    static let identifier = "com.rob.weatheropo.DayWeatherFailedCollectionViewCell"
    let failedIndicator: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(failedIndicator)
    }
    
    private func setupConstraints() {
        failedIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
}

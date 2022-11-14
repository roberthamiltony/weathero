//
//  WeekSummaryViewController.swift
//  weathero
//
//  Created by Robert Hamilton on 13/11/2022.
//

import Foundation
import UIKit
import SwiftUI
import Charts
import SnapKit
import Combine
import CoreLocation

class WeekSummaryViewController: UIViewController {
    private let titleView = WeeklySummaryTitleView()
    private lazy var nextHourView: NextHourView = NextHourView(weatherManager: weatherManager)
    private let nextDaysView: NextDaysView = NextDaysView()
    private let refreshControl = UIRefreshControl()
    
    private var subscriptions: [AnyCancellable] = []
    let weatherManager: WeatherManager = WeatherManager(location: .init(latitude: 51.493169, longitude: -0.098912))
    private lazy var viewModel = WeekSummaryViewModel(weatherManager: weatherManager)
    
    override func viewDidLoad() {
        setupViews()
        setupConstraints()
        setupCollectionView()
        setupSubscriptions()
        weatherManager.getData(dataSets: [.forecastNextHour, .forecastDaily])
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [titleView, nextHourView, nextDaysView].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        titleView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        nextHourView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        nextDaysView.snp.makeConstraints { make in
            make.top.equalTo(nextHourView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualTo(view)
        }
    }
    
    private func setupSubscriptions() {
        weatherManager.$nextDaysData
            .sink { [nextDaysView] _ in
                nextDaysView.collectionView.refreshControl?.endRefreshing()
                nextDaysView.collectionView.reloadData()
            }
            .store(in: &subscriptions)
        viewModel.$locationName
            .map { $0 == nil ? " " : $0 }
            .assign(to: \.title, on: titleView)
            .store(in: &subscriptions)
    }
    
    private func setupCollectionView() {
        nextDaysView.collectionView.register(DayWeatherCollectionViewCell.self, forCellWithReuseIdentifier: DayWeatherCollectionViewCell.identifier)
        nextDaysView.collectionView.register(DayWeatherFailedCollectionViewCell.self, forCellWithReuseIdentifier: DayWeatherFailedCollectionViewCell.identifier)
        nextDaysView.collectionView.register(DayWeatherLoadingCollectionViewCell.self, forCellWithReuseIdentifier: DayWeatherLoadingCollectionViewCell.identifier)
        nextDaysView.collectionView.dataSource = self
        nextDaysView.collectionView.delegate = self
        nextDaysView.collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
    }
    
    @objc private func refreshWeatherData() {
        nextDaysView.collectionView.refreshControl?.beginRefreshing()
        weatherManager.getData(dataSets: [.forecastNextHour, .forecastDaily])
    }
}

extension WeekSummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch weatherManager.nextDaysData {
        case .success(let days):
            return days.count
        case .failure:
            return 1
        case .none:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch weatherManager.nextDaysData {
        case .none:
            return dayWeatherLoadingCell(collectionView, indexPath: indexPath)
        case .success(let days):
            return dayWeatherCell(collectionView, indexPath: indexPath, days: days)
        case .failure:
            return dayWeatherFailedCell(collectionView, indexPath: indexPath)
        }
    }
    
    private func dayWeatherCell(_ collectionView: UICollectionView, indexPath: IndexPath, days: [DailyForecast.DayWeatherCondition]) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayWeatherCollectionViewCell.identifier, for: indexPath)
        guard let day = days.safeGet(indexPath.row), let weatherCell = cell as? DayWeatherCollectionViewCell else { return cell }
        weatherCell.bind(day: day, temperatureRange: viewModel.temperatureRange)
        return weatherCell
    }
    
    private func dayWeatherFailedCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: DayWeatherFailedCollectionViewCell.identifier, for: indexPath)
    }
    
    private func dayWeatherLoadingCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayWeatherLoadingCollectionViewCell.identifier, for: indexPath)
        guard let loadingCell = cell as? DayWeatherLoadingCollectionViewCell else { return cell }
        loadingCell.activityInditcator.startAnimating()
        return loadingCell
    }
}

class WeekSummaryViewModel {
    @Published private(set) var locationName: String?
    var weatherManager: WeatherManager
    
    init(weatherManager: WeatherManager) {
        self.weatherManager = weatherManager
        nameForLocation(location: weatherManager.currentLocation)
    }
    
    var temperatureRange: ClosedRange<Float>? {
        switch weatherManager.nextDaysData {
        case .success(let days):
            guard
                let minimum = days.min(by: {$0.temperatureMin < $1.temperatureMin})?.temperatureMin,
                let maximum = days.max(by: {$0.temperatureMax < $1.temperatureMax})?.temperatureMax
            else {
                return nil
            }
            return (minimum...maximum)
        default:
            return nil
        }
    }
    
    private func nameForLocation(location: CLLocation?) {
        guard let location else {
            locationName = nil
            return
        }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first else {
                self?.locationName = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                return
            }
            self?.locationName = placemark.name ?? "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        }
    }
}

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

protocol WeekSummaryCoordinator: AnyObject {
    
    /// Called by the summary view when a new location is requested
    func weekSummaryDidRequestNewLocation(_ viewController: WeekSummaryViewController)
}

class WeekSummaryViewController: UIViewController {
    private let titleView = WeeklySummaryTitleView()
    private let nextHourView = NextHourView()
    private let nextDaysView: NextDaysView = NextDaysView()
    private let refreshControl = UIRefreshControl()
    private lazy var changeLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = .secondarySystemBackground
        button.addTarget(self, action: #selector(requestNewLocation), for: .touchUpInside)
        button.accessibilityIdentifier = WeekSummaryIdentifiers.requestLocationButton.rawValue
        return button
    }()
    
    private var subscriptions: [AnyCancellable] = []
    let viewModel: WeekSummaryViewModel = WeekSummaryViewModel(location: .init(latitude: 51.493169, longitude: -0.098912))
    
    weak var coordinator: WeekSummaryCoordinator?
    
    override func viewDidLoad() {
        setupViews()
        setupConstraints()
        setupCollectionView()
        setupSubscriptions()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        [titleView, nextHourView, nextDaysView, changeLocationButton].forEach { view.addSubview($0) }
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
            make.left.right.bottom.equalToSuperview()
        }
        changeLocationButton.snp.makeConstraints { make in
            make.bottom.right.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.width.height.equalTo(40)
        }
        changeLocationButton.layer.cornerRadius = 20
    }
    
    private func setupSubscriptions() {
        viewModel.$nextHourData
            .assign(to: \.nextHourData, on: nextHourView.viewModel)
            .store(in: &subscriptions)
        viewModel.$nextDaysData
            .sink { [nextDaysView] _ in
                nextDaysView.collectionView.refreshControl?.endRefreshing()
                nextDaysView.collectionView.reloadData()
            }
            .store(in: &subscriptions)
        viewModel.$currentLocationName
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
        viewModel.getData(dataSets: [.forecastNextHour, .forecastDaily])
    }
    
    @objc private func requestNewLocation() {
        coordinator?.weekSummaryDidRequestNewLocation(self)
    }
}

extension WeekSummaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.nextDaysData {
        case .success(let days):
            return days.count
        case .failure:
            return 1
        case .none:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.nextDaysData {
        case .none:
            return dayWeatherLoadingCell(collectionView, indexPath: indexPath)
        case .success(let days):
            return dayWeatherCell(collectionView, indexPath: indexPath, days: days)
        case .failure:
            return dayWeatherFailedCell(collectionView, indexPath: indexPath)
        }
    }
    
    private func dayWeatherCell(_ collectionView: UICollectionView, indexPath: IndexPath, days: [DayWeatherSummaryModel]) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayWeatherCollectionViewCell.identifier, for: indexPath)
        guard let day = days.safeGet(indexPath.row), let weatherCell = cell as? DayWeatherCollectionViewCell else { return cell }
        weatherCell.bind(day: day, temperatureRange: viewModel.daysTemperatureRange)
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

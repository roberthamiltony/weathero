//
//  LocationPickerViewController.swift
//  weathero
//
//  Created by Robert Hamilton on 14/11/2022.
//

import Foundation
import UIKit
import MapKit

protocol LocationPickerCoordinator: AnyObject {
    func picker(_ viewController: LocationPickerViewController, picked: CLLocation)
}

class LocationPickerViewController: UIViewController {
    let map = MKMapView()
    var proposedLocation: CLLocation? {
        didSet {
            loadViewIfNeeded()
            map.removeAnnotations(map.annotations)
            if let proposedLocation {
                map.centerCoordinate = proposedLocation.coordinate
                let annotation = MKPointAnnotation()
                annotation.coordinate = proposedLocation.coordinate
                map.addAnnotation(annotation)
                UIView.animate(withDuration: 0.25) { [confirmButton] in
                    confirmButton.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.25) { [confirmButton] in
                    confirmButton.isHidden = true
                }
            }
        }
    }
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .label
        button.backgroundColor = .secondarySystemBackground
        button.addTarget(self, action: #selector(confirmLocation), for: .touchUpInside)
        return button
    }()
    
    weak var coordinator: LocationPickerCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupGestures()
    }
    
    private func setupViews() {
        [map, confirmButton].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        map.snp.makeConstraints { $0.edges.equalToSuperview() }
        confirmButton.snp.makeConstraints { make in
            make.bottom.right.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.width.height.equalTo(40)
        }
        confirmButton.layer.cornerRadius = 20
    }
    
    private func setupGestures() {
        map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMap)))
    }
    
    @objc private func didTapMap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let location = gesture.location(in: map)
        let coordinates = map.convert(location, toCoordinateFrom: map)
        proposedLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
    
    @objc private func confirmLocation() {
        if let proposedLocation {
            coordinator?.picker(self, picked: proposedLocation)
        }
    }
}

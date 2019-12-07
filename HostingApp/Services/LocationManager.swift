//
//  LocationManager.swift
//  CustomKeyboard
//
//  Created by Serg Liamthev on 07.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import CoreLocation
import UIKit

protocol LocationManagerDelegate: class {
    
    func didLocationServicesDisabled()
    func onPermissionDenied()
    func onPermissionGranted()
    
    func didRecieveLocationUpdate(_ coordinate: CLLocationCoordinate2D)
}

class LocationManager: NSObject {
    
    weak var delegate: LocationManagerDelegate?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func checkUsersLocationServicesAuthorization() {
        
        guard CLLocationManager.locationServicesEnabled() else {
            delegate?.didLocationServicesDisabled()
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted, .denied:
            delegate?.onPermissionDenied()
            
        case .authorizedWhenInUse, .authorizedAlways:
            
            delegate?.onPermissionGranted()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
        @unknown default:
            assertionFailure("Unknown Core location authorizationStatus")
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        delegate?.didRecieveLocationUpdate(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("CLLocationManager \(error.localizedDescription)")
    }
    
}

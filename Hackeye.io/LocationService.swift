//
//  LocationService.swift
//  Hackeye
//
//  Created by Howard Wang on 2019-06-26.
//  Copyright © 2019 Howard Wang. All rights reserved.
//
// Handles User location request, returns true if success, else false

import Foundation
import CoreLocation // Import CoreLocation Framework

// Handle success/error cases
enum Result<T> {
    case success(T)
    case failure(Error)
}

// Create new CoreLocation Manager Object and initialize
final class LocationService: NSObject {
    private let manager: CLLocationManager
    
    init(manager: CLLocationManager = .init()) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }
    
    var newLocation: ((Result<CLLocation>)-> Void)?
    var didChangeStatus: ((Bool) -> Void)?
    
    var status: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func requestLocationAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func getLocation() {
        manager.requestLocation()
    }
}

// Callback functions (Error case, update newest location, and echo status)
extension LocationService: CLLocationManagerDelegate {
    // If not allowed, return error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        newLocation?(.failure(error))
    }
    
    // Sort by timestamp and update to newest location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.sorted(by: {$0.timestamp > $1.timestamp}).first {
            newLocation?(.success(location))
        }
    }
    
    // If authorization status changed, update status, else stay authorized
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            didChangeStatus?(false)
        default:
            didChangeStatus?(true)
        }
    }
}

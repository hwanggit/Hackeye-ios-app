//
//  LocationServices.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import Foundation
import CoreLocation // Import corelocation library

// Enumerate success, failure cases
enum Result<T> {
    case success(T)
    case failure(Error)
}

// Create location service class and manager
final class LocationService: NSObject {
    private let manager: CLLocationManager
    
    // Initialize location manager
    init(manager: CLLocationManager = .init()) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }
    
    // Handle get new location and detect change enable status
    var newLocation: ((Result<CLLocation>) -> Void)?
    var didChangeStatus: ((Bool) -> Void)?
    
    // Get current status
    var status: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    // Request location authorization
    func requestLocationAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    // Get current location
    func getLocation() {
        manager.requestLocation()
    }
    
    // Function to get filepath url
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

// Extend CLLocationManager to define error, update and change authorization cases
extension LocationService: CLLocationManagerDelegate {
    // If failed to get location, call failure
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        newLocation?(.failure(error))
    }
    
    // If update location, get most recent location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.sorted(by: {$0.timestamp > $1.timestamp}).first {
            newLocation?(.success(location))
            // Get latitude and longitude
            let latitude: String = String(location.coordinate.latitude)
            let longitude: String = String(location.coordinate.longitude)
            
            // Specify filepath
            let filePathLat = self.getDocumentsDirectory().appendingPathComponent("latitude.txt")
            let filePathLng = self.getDocumentsDirectory().appendingPathComponent("longitude.txt")
            
            // Write both coordinates to file, separated by space
            do {
                try latitude.write(to: filePathLat, atomically: true, encoding: String.Encoding.utf8)
                try longitude.write(to: filePathLng, atomically: true, encoding: String.Encoding.utf8)
            }
            catch {
                print("Failed to write coordinates!")
            }
        }
    }
    
    // If authorization status changed, set to true
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            didChangeStatus?(false)
        default:
            didChangeStatus?(true)
        }
    }
}

//
//  LocationViewController.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

// Controller for location permission view
class LocationViewController: UIViewController {

    // Reference to location view object
    @IBOutlet weak var locationView: LocationView!
   
    // Reference to location service object
    var locationService: LocationService?
    
    // After successful loading, call function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instantiate storyboard and app delegate, as well as UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let nav = storyboard.instantiateViewController(withIdentifier: "ProjectNavigationController") as? UINavigationController
        
        // Define variables to store latitude and longitude ("na" by default)
        var latitude : String = "na"
        var longitude : String = "na"
        
        // Define didTapAllow 
        locationView.didTapAllow = { [weak self] in
            self?.locationService?.requestLocationAuthorization()
        }
        
        // Define didTapDeny
        locationView.didTapDeny = { [weak self] in
            self?.locationService?.didChangeStatus!(false)
        }
        
        // If status changed to enabled, request user location
        locationService?.didChangeStatus = { [weak self] success in
            if success {
                self?.locationService?.getLocation()
            }
            else {
                // If already allowed location, load navigation page
                appDelegate.navigationController = nav
                appDelegate.window.rootViewController = nav
                
                // Set delegate
                (nav?.topViewController as? ProjectTableViewController)?.delegate = appDelegate
                
                appDelegate.loadProjects("na", "na")
            }
        }
        
        // Get new location and print out, then change to navigation view
        locationService?.newLocation = { [weak self] result in
            switch result {
            case .success(let location):
                // Set latitude and longitude
                latitude = String(location.coordinate.latitude)
                longitude = String(location.coordinate.longitude)
                
                // If already allowed location, load navigation page
                appDelegate.navigationController = nav
                appDelegate.window.rootViewController = nav
                
                // Get user's current location
                appDelegate.locationService.getLocation()
                
                // Set delegate
                (nav?.topViewController as? ProjectTableViewController)?.delegate = appDelegate
                
                appDelegate.loadProjects(latitude, longitude)
                
            case .failure(let Error):
                print(Error)
                print("Can't get user location.")
            }
        }
    }
}

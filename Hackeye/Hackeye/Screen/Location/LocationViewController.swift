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
        
        // Define didTapAllow 
        locationView.didTapAllow = { [weak self] in
            self?.locationService?.requestLocationAuthorization()
        }
        
        // Define didTapDeny (Transition to navigation view)
        locationView.didTapDeny = { [weak self] in
            appDelegate.window.rootViewController = nav
            appDelegate.loadProjects()
        }
        
        // If status changed to enabled, request user location
        locationService?.didChangeStatus = { [weak self] success in
            if success {
                self?.locationService?.getLocation()
            }
        }
        
        // Get new location and print out, then change to navigation view
        locationService?.newLocation = { [weak self] result in
            switch result {
            case .success(let location):
                print(location)
                
                // Switch to navigation view and load projects
                appDelegate.window.rootViewController = nav
                appDelegate.loadProjects()
                
            case .failure(let error):
                assertionFailure("Error getting the users location \(error)")
            }
        }
    }
}

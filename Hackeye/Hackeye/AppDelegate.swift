//
//  AppDelegate.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Define constant window
    let window = UIWindow()
    
    // Define location and network services
    let locationService = LocationService()
    let networkService = NetworkService()
    
    // Define storyboard and jsonDecoder
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let jsonDecoder = JSONDecoder()
    
    // Function called after successful application launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set JsonDecoder to snakecase
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // If location is enabled, don't show locationView
        switch locationService.status {
        case .notDetermined, .denied, .restricted:
            let locationViewController = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
            locationViewController?.locationService = locationService
            window.rootViewController = locationViewController
            
        default:
            // If already allowed location, load navigation page
            let nav = storyboard.instantiateViewController(withIdentifier: "ProjectNavigationController") as? UINavigationController
            window.rootViewController = nav
            loadProjects()
        }
        // Make window visible
        window.makeKeyAndVisible()
        
        return true
    }
    
    // Function to load project cell
    public func loadProjects() {
        // Get the current URL
        let currentUrl = networkService.setURL("projects", 50, 1, "views")
        
        // Request data and parse URL
        let task1 = URLSession.shared.dataTask(with: currentUrl) { (data, response, error) in
            guard let responseData = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            //parse data received from a network request
            do {
                let root = try self.jsonDecoder.decode(Root.self, from: responseData)
                
                // Get array of view models
                let viewModels = root.projects.compactMap(ProjectListViewModel.init)
                
                // Reference navigation controller
                DispatchQueue.main.async {
                    if let nav = self.window.rootViewController as? UINavigationController,
                        let projectListViewController = nav.topViewController as? ProjectTableViewController {
                            projectListViewController.viewModels = viewModels
                    }
                }
            }
            catch let err{
                print("Error", err)
            }
        }
        
        // Run task
        task1.resume()
    }
}

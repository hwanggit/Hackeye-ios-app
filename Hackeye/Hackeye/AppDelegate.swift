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

    let window = UIWindow()
    let locationService = LocationService()
    let networkService = NetworkService()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let jsonDecoder = JSONDecoder()
    
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
        window.makeKeyAndVisible()
        
        return true
    }
    
    // Function to load project cell
    private func loadProjects() {
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


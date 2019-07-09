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
                
                let viewModels = root.projects.compactMap(ProjectListViewModel.init)
                
                // For reference - How to convert response to JSON object -> Array
                // let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
            
                // Read out projects
                // let jsonArray = jsonResponse!["projects"] as? [Any] ?? []

            }
            catch let err{
                print("Error", err)
            }
        }
        
        // Run task
        task1.resume()
        
        // Instantiate networkService and jsonDecoder
        let networkService2 = NetworkService()
        
        // Get curr User id
        let currUser = "users/1"
        
        // Get the current URL
        let currentUrl2 = networkService2.setURL(currUser , 1, 1, "views")
        
        // Set profile image and label
        let task2 = URLSession.shared.dataTask(with: currentUrl2) { (data, response, error) in
            guard let responseData = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            //parse data received from a network request
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: String]

                // Read out projects
                print(jsonResponse!)
            
            }
            catch let err {
                print("Error", err)
            }
        }
        // Run task
        task2.resume()
        
        // If location is enabled, don't show locationView
        switch locationService.status {
        case .notDetermined, .denied, .restricted:
            let locationViewController = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
            locationViewController?.locationService = locationService
            window.rootViewController = locationViewController
        default:
            assertionFailure()
        }
        window.makeKeyAndVisible()
        
        return true
    }
}


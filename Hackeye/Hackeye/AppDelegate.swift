//
//  AppDelegate.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

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
    
    // Set curr latitude and longitudes
    var currLatitude : String = "na"
    var currLongitude : String = "na"
    
    // Get navigation controller
    var navigationController : UINavigationController?
    
    // Function called after successful application launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set JsonDecoder to snakecase
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // If location is enabled, don't show locationView
        switch locationService.status {
        case .notDetermined, .restricted:
            let locationViewController = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
            locationViewController?.locationService = locationService
            window.rootViewController = locationViewController
            
        default:
            // If already allowed location, load navigation page
            let nav = storyboard.instantiateViewController(withIdentifier: "ProjectNavigationController") as? UINavigationController
            self.navigationController = nav
            window.rootViewController = nav
            
            // Get user's current location
            locationService.getLocation()
            
            // Set delegate
            (nav?.topViewController as? ProjectTableViewController)?.delegate = self
            
            // Specify filepaths to read coordinates from
            let filePathLat = locationService.getDocumentsDirectory().appendingPathComponent("latitude.txt")
            let filePathLng = locationService.getDocumentsDirectory().appendingPathComponent("longitude.txt")
            
            // Define variables to store latitude and longitude
            var latitude : String, longitude : String
            
            // read from files
            do {
                latitude = try String(contentsOf: filePathLat, encoding: .utf8)
                longitude = try String(contentsOf: filePathLng, encoding: .utf8)
                
                // If denied, do NA
                if locationService.status == .notDetermined {
                    latitude = "na"
                    longitude = "na"
                }
                
                // Retrieve latitude and longitude coordinates
                loadProjects(latitude, longitude)
            }
            catch {
                print("Could not read from file")
                loadProjects("na", "na")
            }
        }
        // Make window visible
        window.makeKeyAndVisible()
        
        return true
    }
    
    // Function to load project details
    public func loadDetails(_ viewModel: ProjectListViewModel) {
        (self.navigationController?.topViewController as? DetailsProjectViewController)?.currProject = viewModel
    }
    
    // Function to load project cell
    public func loadProjects(_ latitude: String, _ longitude: String) {
        // Reference navigation controller
        if let nav = self.window.rootViewController as? UINavigationController,
            let projectListViewController = nav.topViewController as? ProjectTableViewController {

            // Get the current URL
            let currentUrl = self.networkService.setHackADayURL("projects", 50, 1, "views")
            
            // Request data and parse URL
            let task1 = URLSession.shared.dataTask(with: currentUrl) { (data, response, error) in
                guard let responseData = data, error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return
                }
                
                //parse data received from a network request
                do {
                    // Code Root with JSONDecoder
                    let root = try self.jsonDecoder.decode(Root.self, from: responseData)
                    
                    // Get array of view models
                    let viewModels = root.projects.compactMap(ProjectListViewModel.init)
                    
                    // Initialize projectListViewController
                    projectListViewController.viewModels = viewModels
                    
                    // For each project, call get user and location, then set instance of projectlistViewcontroller
                    for i in 0...viewModels.count - 1 {
                        self.LoadUsersAndLocations(viewModels[i], projectListViewController)
                        if i == viewModels.count - 1 {
                            projectListViewController.reloadData()
                        }
                    }
                }
                // Catch parsing error
                catch let err{
                    print("Error", err)
                }
            }
            
            // Run task
            task1.resume()
            projectListViewController.currLatitude = latitude
            projectListViewController.currLongitude = longitude
            
            // Set app delegate's coordinates
            self.currLatitude = latitude
            self.currLongitude = longitude
        }
    }
    
    // Function to generate array of users and location
    func LoadUsersAndLocations(_ currProject: ProjectListViewModel, _ ListViewController: ProjectTableViewController) {
        // Get curr User id
        let currUser = "users/" + String(currProject.ownerId)
        
        // Get the current URL
        let currentUrl = self.networkService.setHackADayURL(currUser , 1, 1, "views")
        
        // Set profile image and label
        let task2 = URLSession.shared.dataTask(with: currentUrl) { (data, response, error) in
            guard let responseDataUser = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            // Try to decode response data, and set user image, username
            do {
                let user = try self.jsonDecoder.decode(User.self, from: responseDataUser)
                
                // Append user array
                ListViewController.UserPop.append(user)
                
                // Get url for openGateData
                guard let locationUrl = self.networkService.setOpenCageDataUrl(user.location) else {
                    return
                }

                // Get user location via openCageData
                let task3 = URLSession.shared.dataTask(with: locationUrl) { (data, response, error) in
                    guard let responseDataLocation = data, error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return
                    }
                    
                    // Serialize response
                    do {
                        // Convert response to parsable object
                        let jsonResponse = try JSONSerialization.jsonObject(with: responseDataLocation, options: []) as? [String: Any]
                        let jsonArray = jsonResponse!["results"] as? [Any] ?? []
                        
                        // If array empty, append nil
                        if jsonArray.isEmpty {
                            // Set member of table conroller
                            ListViewController.UserLocations.append(nil)
                            return
                        }
                        
                        // Otherwise convert to object
                        let jsonObject = jsonArray[0] as? [String : Any] ?? [:]
                        let geometry = jsonObject["geometry"] as? [String : Double] ?? [:]
                        
                        // Get latitude and longitude
                        let lat = geometry["lat"]!
                        let lng = geometry["lng"]!
                        
                        // Convert to CLLocationCoordinates
                        let currCoord = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        
                        // Set member of table conroller
                        ListViewController.UserLocations.append(currCoord)
                    }
                    catch let err{
                        print("Error", err)
                        
                    }
                }
                // Run task 3
                task3.resume()
            }
            // Catch error
            catch let err{
                print("Error", err)
            }
        }
        // Run task 2
        task2.resume()
    }
}

// Handle tap cell
extension AppDelegate: ListActions {
    func didTapCell(_ viewModel: ProjectListViewModel) {
        loadDetails(viewModel)
    }
}

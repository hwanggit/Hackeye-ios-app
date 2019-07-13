//
//  ProjectTableViewCell.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit
import Foundation

// Class defining single project cell in table
class ProjectTableViewCell: UITableViewCell {
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var projectImage: UIImageView!
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var projectSummary: UILabel!
    @IBOutlet weak var projectDist: UILabel!
    
    // Set user profile link
    var userLink: String?
    
    // Instantiate networkService and jsonDecoder
    let networkService2 = NetworkService()
    let jsonDecoder = JSONDecoder()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // Add open link function to image
    @IBAction func openURL(sender: UIButton) {
        guard let url = URL(string: self.userLink!) else { return }
        UIApplication.shared.open(url)
    }
    
    // Configure views and fill them
    func configure(with viewModel: ProjectListViewModel, _ latitude: String, _ longitude: String) {
        // Set JsonDecoder to snakecase
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Get curr User id
        let currUser = "users/" + String(viewModel.ownerId)
        
        // Get the current URL
        let currentUrl2 = self.networkService2.setHackADayURL(currUser , 1, 1, "views")
        
        // Set profile image and label
        let task2 = URLSession.shared.dataTask(with: currentUrl2) { (data, response, error) in
            guard let responseData = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            // Try to decode response data, and set user image, username
            do {
                let user = try self.jsonDecoder.decode(User.self, from: responseData)
                
                // Load user image and screen name
                self.userProfile.load(user.imageUrl)
                
                DispatchQueue.main.async {
                    self.userLabel.text = user.screenName.capitalizingFirstLetter()
                }
                
                // Set user link member var
                self.userLink = user.url
                
                // Get url for openGateData
                guard let currentUrl3 = self.networkService2.setOpenCageDataUrl(user.location) else {
                    return
                }
                
                // Get user location via openCageData
                let task3 = URLSession.shared.dataTask(with: currentUrl3) { (data, response, error) in
                    guard let responseData = data, error == nil else {
                        print(error?.localizedDescription ?? "Response Error")
                        return
                    }
                    
                    // Serialize response
                    do {
                        // Convert response to parsable object
                        let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                        let jsonArray = jsonResponse!["results"] as? [Any] ?? []
                        
                        // If location is "na", or if array is empty, display "na" and return
                        if jsonArray.isEmpty || latitude == "na" || longitude == "na" {
                            // Set distance label
                            DispatchQueue.main.async {
                                self.projectDist.text = "N/A"
                            }
                            return
                        }
                        
                        // Otherwise convert to object
                        let jsonObject = jsonArray[0] as? [String : Any] ?? [:]
                        let geometry = jsonObject["geometry"] as? [String : Double] ?? [:]
                        
                        // Get latitude and longitude
                        let lat = geometry["lat"]!
                        let lng = geometry["lng"]!
                        
                        // Convert parameters to double
                        let latDbl = Double(latitude)
                        let lngDbl = Double(longitude)
                        
                        // Calculate distance between user and project location
                        let distance = self.getDistance(latDbl!, lngDbl!, lat, lng)
                        
                        // Set distance label
                        DispatchQueue.main.async {
                            let distInKm = String(Int(distance)) + " km"
                            self.projectDist.text = distInKm
                        }
                    }
                    catch let err{
                        print("Error", err)
                        
                    }
                }
                task3.resume()
                
                // For reference - How to convert response to JSON object -> Array
                // let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                // let jsonArray = jsonResponse!["projects"] as? [Any] ?? []
 
            }
            catch let err{
                print("Error", err)
            }
        }
        // Run task
        task2.resume()
        
        // Set project image if available
        if let projectImageLink = viewModel.imageUrl {
            projectImage.load(projectImageLink)
        }
        
        projectImage.layer.cornerRadius = 5
        
        // Set project name
        projectNameLabel.text = viewModel.name.capitalizingFirstLetter()
        
        // Set project summary
        projectSummary.text = viewModel.summary
        
        // Give containerView a shadow
        overlay.layer.cornerRadius = 5
    }
    
    // Calculate distance given two earth coordinates
    func getDistance(_ lat1: Double, _ lng1: Double, _ lat2: Double, _ lng2: Double) -> Double{
        let R = 6371.0; // Radius of the earth in km
        
        // Convert from deg to radians
        let dLat = degtorad(lat2-lat1)
        let dLon = degtorad(lng2-lng1)
        
        // Calculate distance using formula
        let alpha = sin(dLat/2) * sin(dLat/2) + cos(degtorad(lat1)) * cos(degtorad(lat2)) * sin(dLon/2) * sin(dLon/2)
        
        // Get constant
        let const = 2 * atan2(sqrt(alpha), sqrt(1-alpha))
        
        // Convert to Km
        let dist = R * const
        
        return dist
    }
    
    // Convert degrees to radians
    func degtorad(_ deg: Double) -> Double{
        return deg * (Double.pi/180)
    }
}

// Function to capitalize first letter
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

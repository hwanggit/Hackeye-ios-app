//
//  ProjectTableViewCell.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

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
    func configure(_ viewModel: ProjectListViewModel, _ user: User, _ location: CLLocationCoordinate2D?, _ latitude: String, _ longitude: String) {
        print(location)
        // Set project details and image if available
        if let projectImageLink = viewModel.imageUrl {
            self.projectImage.load(projectImageLink)
        }
        // Set image radius to 5
        self.projectImage.layer.cornerRadius = 5
        
        // Set project name
        self.projectNameLabel.text = viewModel.name.capitalizingFirstLetter()
        
        // Set project summary
        self.projectSummary.text = viewModel.summary
        
        // Give containerView a shadow
        self.overlay.layer.cornerRadius = 5
        
        // Set user link member var
        self.userLink = user.url
        
        // set user details
        self.userLabel.text = user.screenName.capitalizingFirstLetter()
        
        // Load user image
        self.userProfile.load(user.imageUrl)
        
        // If location is "na", or if array is empty, display "na" and return
        if location == nil {
            // Set distance label and return
            self.projectDist.text = "N/A"
            return
        }
        
        // Convert parameters to double
        let myLatDbl = Double(latitude)
        let myLngDbl = Double(longitude)
        let lat = Double(location!.latitude)
        let lng = Double(location!.longitude)
        
        // Calculate distance between user and project location
        let distance = self.getDistance(myLatDbl!, myLngDbl!, lat, lng)
        
        // Set distance label
        let distInKm = String(Int(distance)) + " km"
        self.projectDist.text = distInKm
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

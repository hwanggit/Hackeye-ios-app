//
//  ProjectTableViewCell.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

// Class defining single project cell in table
class ProjectTableViewCell: UITableViewCell {
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var projectImage: UIImageView!
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var projectSummary: UILabel!
    
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

    // Configure views and fill them
    func configure(with viewModel: ProjectListViewModel) {
        // Set JsonDecoder to snakecase
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Get curr User id
        let currUser = "users/" + String(viewModel.ownerId)
        
        // Get the current URL
        let currentUrl2 = self.networkService2.setURL(currUser , 1, 1, "views")
        
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
                    self.userLabel.text = user.screenName
                }
                
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
        
        // Set project image
        projectImage.load(viewModel.imageUrl)
        projectImage.layer.cornerRadius = 5
        
        // Set project name
        projectNameLabel.text = viewModel.name
        
        // Set project summary
        projectSummary.text = viewModel.summary
        
        // Give containerView a shadow
        overlay.layer.cornerRadius = 5
    }
}


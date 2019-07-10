//
//  ProjectTableViewCell.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {
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
            
            do {
                let user = try self.jsonDecoder.decode(User.self, from: responseData)
                
                DispatchQueue.main.async {
                    do {
                        let url = URL(string: user.imageUrl)!
                        let data = try Data(contentsOf: url)
                        self.userProfile.image = UIImage(data: data)
                        
                        // Round image
                        self.userProfile.layer.cornerRadius = self.userProfile.frame.size.width / 2
                        self.userProfile.clipsToBounds = true
                        
                        self.userLabel.text = user.screenName
                    }
                    catch{
                        print("Could not upload user image.")
                    }
                }
                
                // For reference - How to convert response to JSON object -> Array
                /* let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                
                print(jsonResponse!)
                
                
                // Read out projects
                // let jsonArray = jsonResponse!["projects"] as? [Any] ?? []
                */
            }
            catch let err{
                print("Error", err)
            }
        }
        // Run task
        task2.resume()
        
        // Set project image
        do {
            let url = URL(string: viewModel.imageUrl)!
            let data = try Data(contentsOf: url)
            self.projectImage.image = UIImage(data: data)
        }
        catch{
            print("Could not upload project image.")
        }
        
        // Set project name
        projectNameLabel.text = viewModel.name
        
        // Set project summary
        projectSummary.text = viewModel.summary
    }
}


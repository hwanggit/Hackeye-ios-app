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
    @IBOutlet weak var projectSummary: UITextField!
    
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
        // Instantiate networkService and jsonDecoder
        let networkService2 = NetworkService()
        
        // Get curr User id
        let currUser = "users/" + String(viewModel.ownerId)
        
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
                let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                
                // Unwrap data
              /*  let jsonArray = jsonResponse as!
                
                // Set user label and profile
                userLabel.text = jsonArray["screen_name"]!
                
                // Set user image
                do {
                    let url = URL(string: jsonArray["image_url"]!)!
                    let data = try Data(contentsOf: url)
                    self.projectImage.image = UIImage(data: data)
                }
                catch{
                    print(error)
                }
                */
            }
            catch let err {
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
            print(error)
        }
        
        // Set project name
        projectNameLabel.text = viewModel.name
        
        // Set project summary
        projectSummary.text = viewModel.summary
        
    }
}


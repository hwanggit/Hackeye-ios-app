//
//  ProjectTableViewController.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

// Controller for project table
class ProjectTableViewController: UITableViewController {

    // Generate array of project list models
    var viewModels = [ProjectListViewModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // Coordinates
    var currLatitude : String?
    var currLongitude : String?
    
    // Instantiate jsonDecoder and network service
    let jsonDecoder = JSONDecoder()
    let networkService = NetworkService()
    
    // Index to load more projects
    var index = 1
    
    // Function after view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // Set number of rows to the size of viewmodels array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModels.count
    }

    // configure cell to display information from viewModels
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Instantiate tableview cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectTableViewCell
        
        // Instantiate view models
        let vm = viewModels[indexPath.row]
        
        // Configure the cell...
        cell.configure(with: vm, self.currLatitude!, self.currLongitude!)
        
        return cell
    }
    
    // Display future cells
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Set JsonDecoder to snakecase
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Check if reached last cell
        if indexPath.row == viewModels.count - 1{
            
            print(self.index)
            
            // Get more if index is greater than 1
            if self.index > 1 {
                // Get the current URL
                let currentUrl = self.networkService.setHackADayURL("projects", 51, 2, "views")

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
                        self.viewModels.append(contentsOf: viewModels)

                    }
                    catch let err{
                        print("Error", err)
                    }
                }

                // Run task
                task1.resume()
            }
            // Increment index
            self.index = self.index + 1
        }

        // Delay reload
        self.perform(#selector(loadTable), with: nil, afterDelay: 2.0)
    }
    
    // Reload table
    @objc func loadTable() {
        self.tableView.reloadData()
    }
}

/*
// Override to support conditional editing of the table view.
override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
}
*/

/*
// Override to support editing the table view.
override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        // Delete the row from the data source
        tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

}
*/

/*
// Override to support conditional rearranging of the table view.
override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
}
*/

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/

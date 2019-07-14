//
//  ProjectTableViewController.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit
import CoreLocation

// Action protocol for generating details
protocol ListActions: class {
    func didTapCell(_ viewModel: ProjectListViewModel, _ currLocation: CLLocationCoordinate2D?)
}

// Controller for project table
class ProjectTableViewController: UITableViewController {

    // Generate array of project list models
    var viewModels = [ProjectListViewModel]() {
        didSet {
            DispatchQueue.main.async {
                    // Reload data with delay
                self.perform(#selector(self.reloadData), with: nil, afterDelay: 1.5)
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
    var cellIndex : Int = 1
    
    // Notify tap cell
    weak var delegate: ListActions?
    
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
        if indexPath.row == viewModels.count - 1 {
            // Get more if index is greater than 1
            if self.cellIndex > 1 {
                
                // Get the current URL
                let currentUrl = self.networkService.setHackADayURL("projects", 50, self.cellIndex, "views")
                
                // Request data and parse URL
                let task = URLSession.shared.dataTask(with: currentUrl) { (data, response, error) in
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
                task.resume()
            }
            // Increment index
            self.cellIndex = self.cellIndex + 1
        }
    }

    // Call function on click
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Instantiate tableview cell
        let cell = tableView.cellForRow(at: indexPath) as? ProjectTableViewCell
        
        // Get current coordinate
        let currCoordinate = cell?.coordinate

        // Get current project
        let currProject = viewModels[indexPath.row]
        
        // Set currProject
        delegate?.didTapCell(currProject, currCoordinate)
    }
    
    // Manual Reload data
    @objc func reloadData() {
        self.tableView.reloadData()
    }
}

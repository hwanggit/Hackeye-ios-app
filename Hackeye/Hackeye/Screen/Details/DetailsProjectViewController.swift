//
//  DetailsProjectViewController.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation

// Controller for details view
class DetailsProjectViewController: UIViewController {
    
    // Details view instance
    @IBOutlet weak var detailsProjectView: DetailsProjectView?
    
    // Scroll View instance
    @IBOutlet weak var detailsScrollView: UIScrollView?
    
    // Reference viewmodel for projects
    var currProject : ProjectListViewModel? {
        didSet {
            setImageArr()
        }
    }
    
    // Curr location
    var currCoordinate : CLLocationCoordinate2D?
    var userLatitude: String?
    var userLongitude : String?
    
    // Array of image urls
    var imageArr = [String]()
    
    // Instantiate network service and jsondecoder
    let networkService = NetworkService()
    let jsonDecoder = JSONDecoder()
    
    // Function after loading successfully
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow scroll view to scroll label
        detailsScrollView?.contentLayoutGuide.bottomAnchor.constraint(equalTo: detailsProjectView!.projectDescription!.bottomAnchor).isActive = true
        
        // Get projects
        guard let currProject = self.currProject else {
            return
        }
        
        // Shorten numbers
        let views = (currProject.views >= 10000) ? Double(currProject.views/100)/10.0 : Double(currProject.views)
        let followers = (currProject.followers >= 10000) ? Double(currProject.followers/100)/10.0 : Double(currProject.followers)
        let skulls = (currProject.skulls >= 10000) ? Double(currProject.skulls/100)/10.0 : Double(currProject.skulls)
        let comments = (currProject.comments >= 10000) ? Double(currProject.comments/100)/10.0 : Double(currProject.comments)

        // Set page details
        detailsProjectView?.commentsLabel?.text = (currProject.comments >= 10000) ? String(comments) + "K" : String(Int(comments))
        detailsProjectView?.followersLabel?.text = (currProject.followers >= 10000) ? String(followers) + "K" : String(Int(followers))
        detailsProjectView?.skullsLabel?.text = (currProject.skulls >= 10000) ? String(skulls) + "K" : String(Int(skulls))
        detailsProjectView?.viewsLabel?.text = (currProject.views >= 10000) ? String(views) + "K" : String(Int(views))
        detailsProjectView?.projectDescription?.text = currProject.description.html2String
        
        // Do any additional setup after loading the view.
        detailsProjectView?.collectionView?.register(DetailsCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        detailsProjectView?.collectionView?.dataSource = self
        detailsProjectView?.collectionView?.delegate = self
        detailsProjectView?.collectionView?.reloadData()
        
        // Set title
        var components = currProject.name.components(separatedBy: " ")
        
        // Capitalize each word
        for i in 0...components.count - 1 {
            components[i] = components[i].capitalizingFirstLetter()
        }
        
        // Do something with the first component.
        if components.count < 4 {
            title = currProject.name.capitalizingFirstLetter()
        }
        else {
            title = components[0] + " " + components[1] + " " + components[2] + " " + components[3] + "..."
        }
        
        // fill map view
        setMapMark(self.currCoordinate, currProject)
    }
    
    // Set image array
    func setImageArr() {
        
        // get id and image count
        guard let currProject = self.currProject else {
            return
        }
        
        // Get the current URL
        let currentUrl = self.networkService.setHackADayURL("projects/" + String(currProject.id) + "/images", currProject.images, 1, "")
        
        // Request data and parse URL
        let task = URLSession.shared.dataTask(with: currentUrl) { (data, response, error) in
            guard let responseData = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            //parse data received from a network request
            do {
                // Code Root with JSONDecoder
                let imageData = try self.jsonDecoder.decode(ImageObject.self, from: responseData)
                
                // Append url to imagearr
                for i in 0...imageData.images.count - 1 {
                    self.imageArr.append(imageData.images[i].url)
                }
            }
            catch let err{
                print("Error", err)
            }
        }
        
        // Run task
        task.resume()
    }
    
    // Set map marker
    func setMapMark(_ currCoord: CLLocationCoordinate2D?, _ currProject : ProjectListViewModel) {
        
        // Set user location if not equal to na
        if self.userLatitude != "na" && self.userLongitude != "na" {
            detailsProjectView?.mapView?.showsUserLocation = true
        }
        else {
            detailsProjectView?.mapView?.showsUserLocation = false
        }
        
        // Convert coordinates
        guard let currLocation = currCoord else {
            return
        }
        
        // Set annotation for project location
        let projectAnnotation = MKPointAnnotation()
        projectAnnotation.title = currProject.name.capitalizingFirstLetter()
        projectAnnotation.coordinate = currLocation

        // Annotate coordinate region
        let region = MKCoordinateRegion(center: currLocation, latitudinalMeters: 600000, longitudinalMeters: 600000)
        
        // set region on map and add annotation
        detailsProjectView?.mapView?.addAnnotation(projectAnnotation)
        detailsProjectView?.mapView?.setRegion(region, animated: true)
    }
}

// Conform to UICollectionView Protocol
extension DetailsProjectViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // Define number of images
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currProject?.images ?? 0
    }
    
    // Populate cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! DetailsCollectionViewCell
        
        // Set collectionView Urls
        if indexPath.item < self.imageArr.count {
            let url = self.imageArr[indexPath.item]
            cell.imageView.load(url)
        }
        
        return cell
    }
    
    // Make size same as bounds
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    // Will display
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        detailsProjectView?.pageControl?.numberOfPages = self.imageArr.count
        detailsProjectView?.pageControl?.currentPage = indexPath.item
    }
}

// Extensions to convert html to text
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

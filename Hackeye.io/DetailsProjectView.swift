//
//  DetailsProjectView.swift
//  Hackeye
//
//  Created by Howard Wang on 2019-06-26.
//  Copyright © 2019 Howard Wang. All rights reserved.
//

import UIKit
import MapKit

@IBDesignable class DetailsProjectView: BaseView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var skullsLabel: UILabel!
    @IBOutlet weak var projectDescription: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func handleControl(_ sender: UIPageControl) {
        
    }
}

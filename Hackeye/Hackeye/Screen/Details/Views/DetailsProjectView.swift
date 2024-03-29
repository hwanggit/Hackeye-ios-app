//
//  DetailsProjectView.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit
import MapKit

// Details projectView instance class
@IBDesignable class DetailsProjectView: BaseView {
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet weak var viewsLabel: UILabel?
    @IBOutlet weak var followersLabel: UILabel?
    @IBOutlet weak var skullsLabel: UILabel?
    @IBOutlet weak var commentsLabel: UILabel?
    @IBOutlet weak var projectDescription: UILabel?
    @IBOutlet weak var mapView: MKMapView?
}


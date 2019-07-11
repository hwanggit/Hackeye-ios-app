//
//  LocationView.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

// Instance for location permission view
@IBDesignable class LocationView: BaseView {
    
    // Instances for allow and deny buttons
    @IBOutlet weak var allowButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    
    // Functions for allow and deny actions
    var didTapAllow: (() -> Void)?
    var didTapDeny: (() -> Void)?
    
    // If allow, call didTapAllow
    @IBAction func allowAction(_ sender: UIButton) {
        didTapAllow?()
    }
    
    // If denied, call didTapDeny
    @IBAction func denyAction(_ sender: UIButton) {
        didTapDeny?()
    }
}

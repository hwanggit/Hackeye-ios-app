//
//  LocationView.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

@IBDesignable class LocationView: BaseView {
    
    @IBOutlet weak var allowButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    let storyboard = UIStoryboard()
    let appDelegate = AppDelegate()
    
    // Define allow and deny functions
    var didTapAllow: (() -> Void)?
    var didTapDeny: (() -> Void)?
    
    @IBAction func allowAction(_ sender: UIButton) {
        didTapAllow?()
    }
    
    @IBAction func denyAction(_ sender: UIButton) {
        didTapDeny?()
    }
}

//
//  BaseView.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

// UIView instance, acts as superclass to all views
@IBDesignable class BaseView: UIView {

    // Initialize UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    // Initialize NSCoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    // Configure UIView
    func configure() {

    }
}

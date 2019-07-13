//
//  DetailsCollectionViewCell.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/12/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import UIKit

class DetailsCollectionViewCell : UICollectionViewCell {
    // Get image view
    let imageView = UIImageView()
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    // Required initializer
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup function
    func setup() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        // Add image contraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}

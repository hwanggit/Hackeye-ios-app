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
    @IBOutlet weak var navigationMarker: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var navigationLabel: UILabel!
    @IBOutlet weak var projectSummary: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

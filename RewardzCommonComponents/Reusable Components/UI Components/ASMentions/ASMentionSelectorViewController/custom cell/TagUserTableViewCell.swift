//
//  TagUserTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit Sachan on 04/12/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class TagUserTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage : UIImageView?
    @IBOutlet weak var userDisplayName : UILabel?
    @IBOutlet weak var department : UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

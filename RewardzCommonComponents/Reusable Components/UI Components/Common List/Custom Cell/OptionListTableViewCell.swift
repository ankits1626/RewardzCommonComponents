//
//  OptionListTableViewCell.swift
//  SKOR
//
//  Created by Rewardz on 20/12/17.
//  Copyright © 2017 Rewradz Private Limited. All rights reserved.
//

import UIKit

class OptionListTableViewCell: UITableViewCell {
    @IBOutlet weak var optionTitle : UILabel!
    @IBOutlet weak var checkBox : ASCheckBox!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

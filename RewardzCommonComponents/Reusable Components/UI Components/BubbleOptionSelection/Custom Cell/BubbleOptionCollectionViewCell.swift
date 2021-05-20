//
//  BubbleOptionCollectionViewCell.swift
//  BubbleOptionSelector
//
//  Created by Rewardz on 01/11/19.
//  Copyright © 2019 TuringMobile. All rights reserved.
//

import UIKit

public class BubbleOptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet public  weak var titleLabel : UILabel?
    @IBOutlet public  weak var selectionIndicator : UIView?
    private var isHeightCalculated: Bool = false
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

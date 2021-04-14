//
//  HorizontalScrollingOptionCell.swift
//  Nexperia Now
//
//  Created by Rewardz on 04/01/19.
//  Copyright © 2019 Rewradz Private Limited. All rights reserved.
//

import UIKit

class HorizontalScrollingOptionCell: UICollectionViewCell {

    @IBOutlet weak var titleLBL : UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.width = ceil(size.width)
        frame.size.height = ceil(size.height) - 5.0
        layoutAttributes.frame = frame
        self.layer.cornerRadius = (frame.size.height)/2.0
        return layoutAttributes
    }
}

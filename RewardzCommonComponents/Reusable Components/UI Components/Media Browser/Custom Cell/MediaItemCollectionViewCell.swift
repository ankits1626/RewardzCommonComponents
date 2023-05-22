//
//  MediaItemCollectionViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public class MediaItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet public weak var mediaCoverImageView : UIImageView?
    @IBOutlet public weak var removeButton : BlockButton?
    @IBOutlet public weak var playButton : BlockButton?
    @IBOutlet public var pageControl: UIPageControl!
    @IBOutlet public weak var editTransparentView : UIView?
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

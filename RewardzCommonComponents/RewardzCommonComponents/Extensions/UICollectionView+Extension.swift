//
//  UICollectionView+Extension.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 15/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public extension UICollectionView {
    
    var centerPoint : CGPoint {
        
        get {
            return CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y);
        }
    }
    
    var centerCellIndexPath: IndexPath? {
        
        if let centerIndexPath = self.indexPathForItem(at: self.centerPoint) {
            return centerIndexPath
        }
        return nil
    }
}

//
//  LeftCustomFlowLayout.swift
//  RewardzCommonComponents
//
//  Created by Suyesh Kandpal on 11/07/23.
//

import Foundation
import UIKit

public class LeftCustomFlowLayout:UICollectionViewFlowLayout {
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = 2.0
        let horizontalSpacing:CGFloat = 5
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY
                || layoutAttribute.frame.origin.x == sectionInset.left {
                leftMargin = sectionInset.left
            }
            
            if layoutAttribute.frame.origin.x == sectionInset.left {
                leftMargin = sectionInset.left
            }
            else {
                layoutAttribute.frame.origin.x = leftMargin
            }
            
            leftMargin += layoutAttribute.frame.width + horizontalSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}


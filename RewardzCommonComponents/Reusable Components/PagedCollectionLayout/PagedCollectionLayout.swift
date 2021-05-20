//
//  PagedCollectionLayout.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import UIKit

public protocol PagedCollectionLayoutDelegate {
    func currentPageSelected(currentPage : Int)
}

public class PagedCollectionLayout: UICollectionViewFlowLayout {

    public var previousOffset : CGFloat = 0
    public var currentPage : CGFloat = 0
    public var pageCollectionLayoutDelegate : PagedCollectionLayoutDelegate?
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let sup = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        guard
            let validCollection = collectionView,
            let dataSource = validCollection.dataSource
            else { return sup }
        let itemsCount = dataSource.collectionView(validCollection, numberOfItemsInSection: 0)
        // Imitating paging behaviour
        // Check previous offset and scroll direction
        if  (previousOffset > validCollection.contentOffset.x) && (velocity.x < 0) {
            currentPage = max(currentPage - 1, 0)
        }
        else if (previousOffset < validCollection.contentOffset.x) && (velocity.x > 0) {
            currentPage = min(currentPage + 1, CGFloat(itemsCount - 1))
        }
        let updatedOffset : CGFloat = (currentPage) * (UIScreen.main.bounds.size.width - 40 + 10) - 10
        self.previousOffset = updatedOffset
        let updatedPoint = CGPoint(x: updatedOffset, y: proposedContentOffset.y)
        self.pageCollectionLayoutDelegate?.currentPageSelected(currentPage: Int(currentPage))
        return updatedPoint
    }
}


//
//  HorizontolScrolling.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import UIKit

public protocol HorizontalScrollerActionListener {
    func tappedItem(index: Int)
}

public protocol HorizontalScrollingItemConfiguratorProtocol {
    var actionListener : HorizontalScrollerActionListener? {get set}
    var cellIdentifier : String!{get}
    func registerCollectionViewForRespectiveCell(collectionView : UICollectionView)
    func getNumberOfItems() -> Int
    func getCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func configureCell(cell: UICollectionViewCell , indexPath: IndexPath)
    func getSizeOfItem(collectionView : UICollectionView, indexPath : IndexPath) -> CGSize
    func tappedOnItemAtIndex(index: Int)
}

open class  HorizontolScrolling : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    public var horizontalScrollConfigurator : HorizontalScrollingItemConfiguratorProtocol!
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return horizontalScrollConfigurator.getNumberOfItems()
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return horizontalScrollConfigurator.getCell(collectionView:collectionView, indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        horizontalScrollConfigurator.configureCell(cell: cell, indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return horizontalScrollConfigurator.getSizeOfItem(collectionView : collectionView, indexPath: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        horizontalScrollConfigurator.tappedOnItemAtIndex(index: indexPath.row)
        collectionView.reloadData()
    }
}

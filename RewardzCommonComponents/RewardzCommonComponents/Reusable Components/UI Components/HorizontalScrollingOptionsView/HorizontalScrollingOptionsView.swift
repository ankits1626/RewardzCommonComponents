//
//  HorizontalScrollingOptionsView.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import UIKit

public protocol HorizontalScrollingOptionsDelegate {
    func didSelectItemAt(_ index : Int)
}

public protocol HorizontalScrollingOptionsDatasource {
    func numberOfItems() -> Int
    func configureItemCell(_ cell : UICollectionViewCell, index : Int)
}

@IBDesignable public class HorizontalScrollingOptions: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBInspectable public var selectedBubbleColor  = UIColor.selectedOrangeColor
    @IBInspectable public var unSelectedBubbleColor  = UIColor.unSelectedGrayColor
    @IBInspectable public var selectedBubbleTextColor  = UIColor.white
    @IBInspectable public var unSelectedBubbleTextColor  = UIColor.unSelectedTextColor
    public var inferSizeForFixedNumberOfItems : Int?
    fileprivate var delegate : HorizontalScrollingOptionsDelegate?
    fileprivate var dataSource : HorizontalScrollingOptionsDatasource?
    private var optionCollection : UICollectionView!
    private var selectedIndex : Int = 0{
        didSet{
            if let previousCell = optionCollection.cellForItem(at: IndexPath(item: oldValue, section: 0)) as? HorizontalScrollingOptionCell{
                    previousCell.backgroundColor = unSelectedBubbleColor
                previousCell.titleLBL?.textColor = unSelectedBubbleTextColor
                }
            if let currentCell = optionCollection.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? HorizontalScrollingOptionCell{
                currentCell.backgroundColor = selectedBubbleColor
                currentCell.titleLBL?.textColor = selectedBubbleTextColor
            }
            optionCollection.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    public func loadData(_ selectedIndex :  Int = 0) {
        optionCollection.reloadData()
        self.selectedIndex = selectedIndex
    }
    
    public func setDelegate(_ delegate : HorizontalScrollingOptionsDelegate){
        self.delegate = delegate
    }
    
    public func setDatasource(_ datasource : HorizontalScrollingOptionsDatasource){
        self.dataSource = datasource
    }
    
    private func setup(){
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        if let unwrappedItems = inferSizeForFixedNumberOfItems,
        unwrappedItems > 0{
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width / CGFloat(unwrappedItems), height:26.7)
        }else{
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
        }
        layout.scrollDirection = .horizontal
        optionCollection = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        optionCollection.register(UINib(nibName: "HorizontalScrollingOptionCell", bundle: Bundle(for: HorizontalScrollingOptionCell.self)), forCellWithReuseIdentifier: "HorizontalScrollingOptionCell")
        optionCollection.dataSource = self
        optionCollection.delegate = self
        optionCollection.backgroundColor = UIColor.clear
        optionCollection.showsHorizontalScrollIndicator = false
        optionCollection.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        optionCollection.frame = self.bounds
        self.addSubview(optionCollection)
        optionCollection.reloadData()
        //optionCollection.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        //optionCollection.reloadData()
        if dataSource != nil{
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            if let unwrappedItems = inferSizeForFixedNumberOfItems,
            unwrappedItems > 0{
                layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 10) / CGFloat(unwrappedItems), height:26.7)
            }else{
                layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
                layout.itemSize = UICollectionViewFlowLayout.automaticSize
            }
            layout.scrollDirection = .horizontal
            optionCollection.collectionViewLayout = layout
            optionCollection.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItems() ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalScrollingOptionCell",
                                                            for: indexPath) as? HorizontalScrollingOptionCell
            else { fatalError("unexpected cell in collection view") }
        dataSource?.configureItemCell(cell, index: indexPath.row)
        cell.titleLBL?.textColor = selectedIndex == indexPath.item ? selectedBubbleTextColor : unSelectedBubbleTextColor
        cell.backgroundColor = selectedIndex == indexPath.item ? selectedBubbleColor : unSelectedBubbleColor
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        delegate?.didSelectItemAt(indexPath.item)
    }
    
}


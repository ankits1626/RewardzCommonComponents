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
    @IBInspectable public var selectedBubbleBorderColor : UIColor?
    @IBInspectable public var unSelectedBubbleColor  = UIColor.unSelectedGrayColor
    @IBInspectable public var selectedBubbleTextColor  = UIColor.white
    @IBInspectable public var unSelectedBubbleTextColor  = UIColor.unSelectedTextColor
    @IBInspectable public var unSelectedBubbleBorderColor : UIColor?
    var organisationColor : String = ""
    public var isFromPoll = false
    public var inferSizeForFixedNumberOfItems : Int?
    fileprivate var delegate : HorizontalScrollingOptionsDelegate?
    var dataSource : HorizontalScrollingOptionsDatasource?
    public var optionCollection : UICollectionView!
    private var selectedIndex : Int = 0{
        didSet{
            if let previousCell = optionCollection.cellForItem(at: IndexPath(item: oldValue, section: 0)) as? HorizontalScrollingOptionCell{
                previousCell.backgroundColor = .white
                previousCell.titleLBL?.textColor = .lightGray
                }
            if let currentCell = optionCollection.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? HorizontalScrollingOptionCell{
                currentCell.backgroundColor = UIColor.getControlColor()
                currentCell.titleLBL?.textColor = .white
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
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width / CGFloat(unwrappedItems), height:40.0)
        }else{
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
        }
        layout.scrollDirection = .horizontal
        optionCollection = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        optionCollection.register(UINib(nibName: "HorizontalScrollingOptionCell", bundle: Bundle(for: HorizontalScrollingOptionCell.self)), forCellWithReuseIdentifier: "HorizontalScrollingOptionCell")
        optionCollection.dataSource = self
        optionCollection.delegate = self
//        if isFromPoll {
//            optionCollection.backgroundColor = .clear
//        }else {
//            optionCollection.backgroundColor = #colorLiteral(red: 0.9434584975, green: 0.9545181394, blue: 1, alpha: 1)
//        }
        optionCollection.backgroundColor = #colorLiteral(red: 0.9434584975, green: 0.9545181394, blue: 1, alpha: 1)
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
                if isFromPoll {
                    optionCollection.backgroundColor = .clear
                    layout.itemSize = CGSize(width: CGFloat(unwrappedItems) + 10, height:40.0)
                }else {
                    layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 32.0) / CGFloat(unwrappedItems), height:40.0)
                }
                
                //layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 10) / CGFloat(unwrappedItems), height:40.0)
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
        cell.titleLBL?.textColor = selectedIndex == indexPath.item ? .white : .lightGray
        cell.backgroundColor = selectedIndex == indexPath.item ? UIColor.getControlColor() : .white
        
        if selectedIndex == indexPath.item{
            if let unwrappedSelectedBorderColor = selectedBubbleBorderColor{
                cell.borderedControl(borderColor: unwrappedSelectedBorderColor, borderWidth: 1.0)
            }
        }else{
            if let unwrappedUnselectedBorderColor = unSelectedBubbleBorderColor{
                cell.borderedControl(borderColor: unwrappedUnselectedBorderColor, borderWidth: 1.0)
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        delegate?.didSelectItemAt(indexPath.item)
    }
    
}


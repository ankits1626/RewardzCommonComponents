//
//  CustomSegmentedControl.swift
//  Cerrapoints SG
//
//  Created by Rewardz on 23/11/17.
//  Copyright © 2017 Rewradz Private Limited. All rights reserved.
//


import UIKit

enum SegmentedControlType {
    case native
    case custom
}

@IBDesignable public class CustomSegmentedControl: UIControl {
    
    //MARK:- Properties
    @IBInspectable public var markerColor : UIColor = UIColor.blue
    @IBInspectable public var selectedMarkerColor : UIColor = UIColor.black
    @IBInspectable public var indicatorColor : UIColor = UIColor(red: 0.012, green: 0.663, blue: 0.957, alpha: 1.000)
    @IBInspectable public var indicatorHeight : CGFloat = 2.0
    @IBInspectable public var numberOfItems : Int = 0 {
        didSet{
            if (numberOfItems > 0)  {
                var items = [String]()
                for index in 1...self.numberOfItems{
                    items.append("Item \(index)")
                }
                self.items = items
            }
            
        }
    }
    private var labels = [UILabel]()
    var thumbView = UIView()
    let bottomView = UIView()
    public var items : [String] = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6"]{
        didSet{
            setupLabels()
        }
    }
    @IBInspectable public var selectedIndex: Int  = 0 {
        
        willSet{
            let label = labels[selectedIndex]
            label.textColor = markerColor
        }
        
        didSet{
            displayNewSelectedIndex()
        }
        
    }
    
    func setupSegmentedControl(){
        // layer.cornerRadius = frame.height/2
        //        layer.borderColor = UIColor.green.cgColor
        //        layer.borderWidth = 2
        
        //backgroundColor = UIColor.white
        setupLabels()
        insertSubview(thumbView, at: 0)
        bottomView.backgroundColor = UIColor.red
        insertSubview(bottomView, belowSubview: thumbView)
    }
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSegmentedControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSegmentedControl()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectedFrame = self.bounds
        let newWidth = selectedFrame.width / CGFloat(items.count)
        selectedFrame.size.width = newWidth
        selectedFrame.size.height = CGFloat(indicatorHeight)
        thumbView.frame = selectedFrame
        thumbView.backgroundColor = indicatorColor
        thumbView.layer.cornerRadius = thumbView.frame.height/2
        
        let labelHeight = self.bounds.height
        
        let labelWidth = self.bounds.width / CGFloat(labels.count)
        
        for index in 0...labels.count-1 {
            let label = labels[index]
            let previousLabel : UILabel? = index>0 ? labels[index-1] : nil
            let xPosition = previousLabel != nil ?  CGFloat(index) * labelWidth : 0
            
            label.frame = CGRect(x: xPosition == 0 ? 0 : xPosition+15, y: 0, width: labelWidth, height: labelHeight)
            
        }
        displayNewSelectedIndex()
    }
    
    
    private func setupLabels(){
        for label in labels{
            label.removeFromSuperview()
        }
        labels.removeAll(keepingCapacity: true)
        
        for index in 1...items.count{
            let label = UILabel(frame: CGRect.zero)
            label.text = items[index-1]
            label.textAlignment = .center
            label.textColor = markerColor
            label.font = UIFont(name: "SFProText-Semibold", size: 11.5)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.1
            self.addSubview(label)
            labels.append(label)
        }
    }
    
    private func displayNewSelectedIndex(){
        let label = labels[selectedIndex]
        var thumbviewFrame = label.frame
        label.textColor = selectedMarkerColor
        thumbviewFrame.size.height = CGFloat(indicatorHeight)
        thumbviewFrame.origin.y = label.bounds.maxY - CGFloat(indicatorHeight)
        self.thumbView.frame = thumbviewFrame
        bottomView.frame = CGRect(x: 0, y: thumbviewFrame.origin.y, width: self.bounds.width, height: CGFloat(indicatorHeight))
        bottomView.backgroundColor = UIColor.getBackgroundDarkGreyColor
    }
    
    
    //MARK:- touch event
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        var calculatedIndex : Int?
        
        for (index, item) in labels.enumerated(){
            if item.frame.contains(location){
                calculatedIndex = index
            }
        }
        
        if ((calculatedIndex  != nil) && (selectedIndex != calculatedIndex)){
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        return false
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

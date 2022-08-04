//
//  ASCheckBox.swift
//  SKOR
//
//  Created by Rewardz on 08/05/19.
//  Copyright © 2019 Rewradz Private Limited. All rights reserved.
//

import UIKit

public class ASCheckBox: UIView {
    @IBInspectable public var isChecked : Bool = false{
        didSet{
            self.backgroundColor = isChecked ? checkedColor : uncheckedColor
            checkLabel.isHidden = !isChecked
        }
    }
    @IBInspectable public var uncheckedColor: UIColor! = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
    @IBInspectable public var checkedColor: UIColor!{
        get{
            return  UIColor.getControlColor()
        }
    }
    @IBInspectable public var tickColor: UIColor!{
        get{
            return .white
        }
    }
    @IBInspectable public var tickSize : CGFloat = 10.0{
        didSet{
            checkLabel.font = UIFont.systemFont(ofSize: tickSize)
        }
    }
    public var toggleCheckBoxSelectionCompletion : (()-> Void)?
    private var checkLabel : UILabel!
    private func insertControlSubViews() {
        //add check box here
        if checkLabel == nil{
            checkLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width/2.0, height: frame.height/2.0))
            //checkLabel.backgroundColor = .yellow
            checkLabel.textAlignment = .center
            addSubview(checkLabel)
            bringSubviewToFront(checkLabel)
            checkLabel.text = "✓"
        }
        
        checkLabel.isHidden = !isChecked
        checkLabel.textColor = tickColor
        checkLabel.center = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
    }
    
    private var tapGestureRecognizer : UITapGestureRecognizer!
    private func addTapGesture(){
        if tapGestureRecognizer == nil{
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    private func setupCheckBoxControl() {
        self.layer.cornerRadius = frame.size.height/2.0
        insertControlSubViews()
        addTapGesture()
        self.backgroundColor = isChecked ? checkedColor : uncheckedColor
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupCheckBoxControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCheckBoxControl()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    @objc private func handleTap(){
        print("$$$$$ call completion")
        if let unwrappedCompletion = toggleCheckBoxSelectionCompletion{
            unwrappedCompletion()
        }
    }
}

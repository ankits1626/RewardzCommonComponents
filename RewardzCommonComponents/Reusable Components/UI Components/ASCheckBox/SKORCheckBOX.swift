//
//  SKORCheckBOX.swift
//  RewardzCommonComponents
//
//  Created by Suyesh Kandpal on 29/06/22.
//

import UIKit

public class SKORCheckBOX: UIView {
    @IBInspectable public var isChecked : Bool = false{
        didSet{
            self.backgroundColor = isChecked ? checkedColor : uncheckedColor
            checkImageView.isHidden = !isChecked
        }
    }
    @IBInspectable public var uncheckedColor: UIColor! = .clear
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
    private var checkImageView : UIImageView!
    private func insertControlSubViews() {
        //add check box here
        if checkImageView == nil{
            checkImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width/2.0, height: frame.height/2.0))
            addSubview(checkImageView)
            bringSubviewToFront(checkImageView)
            checkImageView.image = UIImage(named: "transparentTick")
            checkImageView.contentMode = .scaleAspectFit
        }
        checkImageView.isHidden = !isChecked
        checkImageView.center  = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
    }
    
    private func setupCheckBoxControl() {
        self.layer.cornerRadius = frame.size.height/2.0
        insertControlSubViews()
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
}


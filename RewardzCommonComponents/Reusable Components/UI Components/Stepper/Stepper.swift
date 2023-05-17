//
//  Stepper.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 29/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public protocol StepperDelegate {
    func stepperDidChanged(sender: Stepper)
}

@IBDesignable public class Stepper: UIControl {
    //MARK:- Properties
    @IBInspectable public var incrementIndicatorColor: UIColor = UIColor.white{
        didSet{
            layoutSubviews()
        }
    }
    @IBInspectable public var decrementIndicatorColor: UIColor = UIColor.white{
        didSet{
            layoutSubviews()
        }
    }
//    @IBInspectable public var indicatorColor: UIColor = UIColor.white
    @IBInspectable public var borderColor: UIColor = UIColor.white
    @IBInspectable public var textColor: UIColor = UIColor.lightGray
    @IBInspectable public var middleColor: UIColor = UIColor.white
    @IBInspectable public var cornerRadius: CGFloat = 12.0
    @IBInspectable public var borderWidth: CGFloat = 2.0
    @IBInspectable public var minVal: NSNumber?
    @IBInspectable public var maxVal: NSNumber?
    @IBInspectable public var quantityErrorMessage: String?
    @IBInspectable public var delta: Int = 1
    @IBInspectable public var incrementImage: UIImage?
    @IBInspectable public var decrementImage: UIImage?
    public var delegate: StepperDelegate?
    
    private var incrementButton = UIButton(frame: CGRect.zero)
    private var decrementButton = UIButton(frame: CGRect.zero)
    public  var counterTxt  = UITextView(frame: CGRect.zero)
    @IBInspectable public var isQuantityFieldEnabled : Bool = true
    @IBInspectable public var isBorderEnabled : Bool = true
    
    public override var isEnabled: Bool{
        didSet {
            isUserInteractionEnabled = isEnabled
        }
    }
    
    @IBInspectable public var reading: Int = 0 {
        didSet {
            counterTxt.text = "\(reading)"
        }
    }
    
    private func insertControlSubViews() {
        decrementButton.addTarget(self, action: #selector(decrement), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(increment), for: .touchUpInside)
        counterTxt.textAlignment = .center
    }
    
    func addButtonToSubView() {
        if isQuantityFieldEnabled {
            self.addSubview(decrementButton)
            self.addSubview(incrementButton)
            self.addSubview(counterTxt)
        }else{
            self.addSubview(counterTxt)
        }
    }
    
    func setupStepperControl() {
        insertControlSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStepperControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStepperControl()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth = self.frame.size.height
        var counterLabelWidth = self.frame.size.width - (2 * buttonWidth)
        counterLabelWidth =  counterLabelWidth > 0 ? counterLabelWidth : 20.0
        let leftButtonframe  = CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height)
        let rightButtonFrame = CGRect(x: (buttonWidth + counterLabelWidth), y: 0, width: self.frame.size.height, height: self.frame.size.height)
        
        let counterLabelFrame = CGRect(x: buttonWidth, y: 0, width: counterLabelWidth, height: self.frame.size.height)
        self.decrementButton.frame = leftButtonframe
        self.incrementButton.frame = rightButtonFrame
        self.counterTxt.frame = counterLabelFrame
        counterTxt.isScrollEnabled = false
        counterTxt.isUserInteractionEnabled = true
        addButtonToSubView()
        if isQuantityFieldEnabled && isBorderEnabled{
//            counterTxt.contentOffset = CGPoint(x: 0, y: -5)
            self.layer.borderWidth = borderWidth
            counterTxt.layer.borderWidth = borderWidth
            counterTxt.layer.borderColor = borderColor.cgColor
        }
        self.incrementButton.roundCorners(corners: [.topRight,.bottomRight,.topLeft, .bottomLeft], radius: 8.0)
        self.decrementButton.roundCorners(corners: [.topRight,.bottomRight,.topLeft, .bottomLeft], radius: 8.0)
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
        counterTxt.backgroundColor = middleColor
        counterTxt.textColor = textColor
        counterTxt.keyboardType = .numberPad
        decrementButton.backgroundColor = UIColor(red: 245, green: 248, blue: 255)
        decrementButton.setTitleColor(UIColor(red: 171, green: 173, blue: 192), for: .normal)
        incrementButton.backgroundColor = incrementIndicatorColor
        decrementButton.setTitle("-", for: UIControl.State.normal)
        incrementButton.setTitle("+", for: UIControl.State.normal)
        setNeedsDisplay()
        NotificationCenter.default.addObserver(self, selector: #selector(readingDidChanged(notification:)), name: UITextView.textDidChangeNotification, object: counterTxt)
    }
    
    @objc func increment() {
        if self.isEnabled == true{
            if let maxVal = self.maxVal?.intValue {
                let compReading = reading + delta
                if compReading <= maxVal{
                    reading = compReading
                    self.delegate?.stepperDidChanged(sender: self)
                }
            }else{
                reading = reading + delta
                self.delegate?.stepperDidChanged(sender: self)
            }
        }
    }
    
    @objc func decrement() {
        if self.isEnabled {
            if let minVal = self.minVal?.intValue {
                let compReading = reading - delta
                if compReading >= minVal{
                    reading = compReading
                    self.delegate?.stepperDidChanged(sender: self)
                }
            } else {
                reading = reading - delta
                self.delegate?.stepperDidChanged(sender: self)
            }
        }
    }
}

extension Stepper: UITextFieldDelegate {
    @objc func readingDidChanged(notification: Notification)  {
        if counterTxt.text.isEmpty{
            reading = 0
        }else{
            reading = checkMaxLimitForStepper(enteredLimit: Int(self.counterTxt.text)!)
        }
        self.delegate?.stepperDidChanged(sender: self)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if counterTxt.text.isEmpty {
            self.counterTxt.text = "0"
        }
    }
    
    func checkMaxLimitForStepper(enteredLimit : Int) -> Int {
        if let maxVal = self.maxVal?.intValue {
            if enteredLimit <= maxVal{
                return enteredLimit
            }else{
                return reading
            }
        }
        return enteredLimit
    }
}

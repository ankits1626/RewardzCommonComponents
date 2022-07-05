//
//  UIView+TopRoundCorners.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public extension UIView {

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {

        var borders = [UIView]()
        subviews.forEach { (aSubview) in
            if aSubview.tag == 99{
                aSubview.removeFromSuperview()
            }
        }
        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.tag = 99
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }


        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }

        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }

        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }

        return borders
    }

    func curvedBorderedControl(borderColor : UIColor = UIColor.getGeneralBorderColor(),borderWidth : CGFloat  = 1.0) {
        self.layer.cornerRadius = 5.0
        borderedControl(borderColor: borderColor, borderWidth: borderWidth)
    }
    
    func curvedWithoutBorderedControl(borderColor : UIColor = UIColor.getGeneralBorderColor(),borderWidth : CGFloat  = 1.0, cornerRadius : CGFloat = 8.0) {
        self.layer.cornerRadius = cornerRadius
        borderedControl(borderColor: borderColor, borderWidth: borderWidth)
    }
    
    func borderedControl(borderColor : UIColor = UIColor.getGeneralBorderColor(), borderWidth : CGFloat  = 1.0 ) {
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    func curvedCornerControl() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 5.0
    }
    
    func drawDottedLine() {
          let shapeLayer:CAShapeLayer = CAShapeLayer()
          let frameSize = self.frame.size
           let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
           shapeLayer.bounds = shapeRect
           shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
           shapeLayer.fillColor = UIColor.clear.cgColor
           shapeLayer.strokeColor = #colorLiteral(red: 0.06274509804, green: 0.4705882353, blue: 0.5803921569, alpha: 1)
           shapeLayer.lineWidth = 1
           shapeLayer.lineJoin = CAShapeLayerLineJoin.round
           shapeLayer.lineDashPattern = [12,3]
           shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 2).cgPath
          self.layer.addSublayer(shapeLayer)
      }
}

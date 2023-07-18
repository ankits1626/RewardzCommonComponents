//
//  ToolTip+UILabel.swift
//  RewardzCommonComponents
//
//  Created by Ankit on 15/07/23.
//
import UIKit

public class ToolTip: UILabel {
    
    public var roundRect:CGRect!
    public override func drawText(in rect: CGRect) {
        super.drawText(in: roundRect)
    }
    
    public override func draw(_ rect: CGRect) {
        roundRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 4 / 5)
        let roundRectBez = UIBezierPath(roundedRect: roundRect, cornerRadius: 10.0)
        let triangleBez = UIBezierPath()
        triangleBez.move(to: CGPoint(x: roundRect.minX + roundRect.width / 2.5, y:roundRect.maxY))
        triangleBez.addLine(to: CGPoint(x:rect.midX,y:rect.maxY))
        triangleBez.addLine(to: CGPoint(x: roundRect.maxX - roundRect.width / 2.5, y:roundRect.maxY))
        triangleBez.close()
        roundRectBez.append(triangleBez)
        let bez = roundRectBez
       // UIColor.red.setFill(
        //ToolTip.UIColorFromRGB(0xE5E5E5)?.setFill()
        ToolTip.UIColorFromRGB(0x000000)?.setFill()
        bez.fill()
        super.draw(rect)
    }
    
    public static func UIColorFromRGB(_ rgbValue: Int) -> UIColor! {
        return UIColor(
            red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0),
            green: CGFloat((Float((rgbValue & 0x00ff00) >> 8)) / 255.0),
            blue: CGFloat((Float((rgbValue & 0x0000ff) >> 0)) / 255.0),
            alpha: 1.0)
    }
    
}

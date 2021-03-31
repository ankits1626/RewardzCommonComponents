//
//  FontApplied.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public extension UIFont{
    static var Title1 : UIFont{
        return UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    static var Body1 : UIFont{
        return UIFont.systemFont(ofSize: 11, weight: .regular)
    }
    
    static var Body3 : UIFont{
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    static var Highlighter1 : UIFont{
        return UIFont.systemFont(ofSize: 10, weight: .bold)
    }
    
    static var Highlighter2 : UIFont{
        return UIFont.systemFont(ofSize: 13, weight: .bold)
    }
    
    static var Caption1 : UIFont{
        return UIFont.systemFont(ofSize: 10, weight: .regular)
    }
    
    static var Caption2 : UIFont{
        return UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    static var Body2 : UIFont{
        return UIFont.systemFont(ofSize: 13, weight: .medium)
    }
    
    static var Button : UIFont{
        return UIFont.systemFont(ofSize: 15, weight: .bold)
    }
    
    static var SemiBold14 : UIFont{
        return UIFont.systemFont(ofSize: 14, weight: .semibold)
    }
    
    static var SemiBold12 : UIFont{
        return UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
}

public extension UIColor{
    
    static var buttonColor:  UIColor {
        return .black
    }
    
    static var buttonTextColor:  UIColor {
        return .white
    }
    
    static var optionContainerBackGroundColor:  UIColor {
        return UIColor(red: 241/255.0, green: 251/255.0, blue: 255/255.0, alpha: 0.55)
    }
    
    static func getTitleTextColor() -> UIColor {
        return UIColor(red: 37/255.0, green: 37/255.0, blue: 37/255.0, alpha: 1.0)
    }
    
    static func getSubTitleTextColor() -> UIColor {
        return UIColor(red: 140/255.0, green: 140/255.0, blue: 140/255.0, alpha: 1.0)
    }
    
    static func getGeneralBorderColor() -> UIColor{
        return UIColor.gray
    }
    
    static func getPlaceholderTextColor() -> UIColor{
        return UIColor.gray
    }
    
    static func grayBackGroundColor() -> UIColor{
        return UIColor(red: 237/255.0, green: 237/255.0, blue: 237/255.0, alpha: 1.0)
    }
    
    static var stepperActiveColor : UIColor{
        return UIColor(red: 251/255.0, green: 137/255.0, blue: 129/255.0, alpha: 1.0)
    }
    
    static var controlInactiveColor : UIColor{
        return UIColor(red: 151/255.0, green: 151/255.0, blue: 151/255.0, alpha: 1.0)
    }
    
    static var stepperInactiveColor : UIColor{
        return UIColor(red: 171/255.0, green: 171/255.0, blue: 171/255.0, alpha: 1.0)
    }
    
    static var stepperMiddleColor : UIColor{
        return UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
    }
    
    static var viewBackgroundColor : UIColor {
        return UIColor(red: 245/255.0, green: 246/255.0, blue: 249/255.0, alpha: 1.0)
    }
    
    static var commentBarBackgroundColor : UIColor {
        return UIColor(red: 246/255.0, green: 247/255.0, blue: 248/255.0, alpha: 1.0)
    }
    
    static var guidenceViewBackgroundColor : UIColor {
        return UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
    }
    
    static var feedCellBorderColor : UIColor {
        return .clear
    }
    
    static var unVotedPollOptionBorderColor : UIColor {
        return UIColor(red: 195/255.0, green: 193/255.0, blue: 193/255.0, alpha: 1.0)
    }
    
    static var votedPollOptionBorderColor : UIColor {
        return .black
    }
    
    static var bottomButtonTextColor : UIColor {
        return .black
    }
    
    static var bottomAssertiveButtonTextColor : UIColor {
        return .white
    }
    
    static var bottomAssertiveBackgroundColor : UIColor {
        return .black
    }
    
    static var bottomDestructiveButtonTextColor : UIColor {
        return .black
    }
    
    static var bottomDestructiveBackgroundColor : UIColor {
        return .white
    }
    
    static var progressColor : UIColor {
        return UIColor(red: 234/255.0, green: 239/255.0, blue: 242/255.0, alpha: 1.0)
    }
    
    static var progressTrackColor : UIColor {
        return .white
    }
    
    static var progressTrackLightColor:  UIColor {
        return UIColor(red: 234/255.0, green: 239/255.0, blue: 242/255.0, alpha: 1.0)
    }
    
    static var progressTrackMaxColor:  UIColor {
        return UIColor(red: 156/255.0, green: 176/255.0, blue: 188/255.0, alpha: 1.0)
    }
    
    static var urlColor : UIColor {
        return UIColor(red: 53.0/255, green: 152.0/255, blue: 220.0/255, alpha: 1)
    }
    
    static var seperatorColor : UIColor {
        return UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
    }
    
    static var borderColor : UIColor {
        return UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 1)
    }
    
}

public struct AppliedCornerRadius {
    public static let standardCornerRadius : CGFloat = 6.0
}

public struct BorderWidths {
    public static let standardBorderWidth : CGFloat = 1.0
    public static let votedOptionBorderWidth : CGFloat = 1.5
}

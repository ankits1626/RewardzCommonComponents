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
    
    static var Highlighter6 : UIFont{
        return UIFont.systemFont(ofSize: 9, weight: .bold)
    }
    
    static var Highlighter1 : UIFont{
        return UIFont.systemFont(ofSize: 10, weight: .bold)
    }
    
    static var Highlighter5 : UIFont{
        return UIFont.systemFont(ofSize: 12, weight: .bold)
    }
    
    static var Highlighter2 : UIFont{
        return UIFont.systemFont(ofSize: 13, weight: .bold)
    }
    
    static var Highlighter3 : UIFont{
        return UIFont.systemFont(ofSize: 14, weight: .bold)
    }
    
    
    static var Highlighter4 : UIFont{
        return UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    static var Caption1 : UIFont{
        return UIFont.systemFont(ofSize: 10, weight: .regular)
    }
    
    static var Caption2 : UIFont{
        return UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    static var Caption3 : UIFont{
        return UIFont.systemFont(ofSize: 13, weight: .regular)
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
    
    static var Medium11 : UIFont{
        return UIFont.systemFont(ofSize: 11, weight: .medium)
    }
    
    static var FloatingButton : UIFont{
        return UIFont.systemFont(ofSize: 12, weight: .medium)
    }
}

public extension UIColor{
    
    static func getControlColor()-> UIColor{
        return RCCThemeDetailProvider.shared.coordinator.getBackgroundColor()
    }
    
    static func getGreyControlColor()-> UIColor{
        return .gray
    }
    
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
    
    static var getBackgroundDarkGreyColor : UIColor{
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
    
    static let selectedOrangeColor = UIColor(red: 243.0/255.0, green: 91/255.0, blue: 45/255.0, alpha: 1.0)
    static let unSelectedGrayColor = UIColor(red: 222.0/255.0, green: 222/255.0, blue: 222/255.0, alpha: 1.0)
    static let unSelectedTextColor = UIColor(red: 66/255.0, green: 66/255.0, blue: 66/255.0, alpha: 1.0)
    
    static func getBackgroundGreyColor() -> UIColor{
        return UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
    }
    
    static func getSelectedBubbleColor() -> UIColor{
        return UIColor.white
    }
    
    static func getSelectedBubbleTextColor() -> UIColor{
        return UIColor(red: 62/255.0, green: 62/255.0, blue: 62/255.0, alpha: 1.0)
    }
    
    static func getUnSelectedBubbleColor() -> UIColor{
        return UIColor.clear
    }
    
    static func getUnSelectedBubbleTextColor() -> UIColor{
        return UIColor(red: 165/255.0, green: 165/255.0, blue: 165/255.0, alpha: 1.0)
    }
    
    static func getSearchBarPlaceHolderTextColor() -> UIColor{
        return UIColor(red: 90/255.0, green: 92/255.0, blue: 93/255.0, alpha: 1.0)
    }
    
    static func getHeaderColor() -> UIColor{
        return .white
    }
    
    static var stepperMiddleColor : UIColor{
        return UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
    }
    
    static var pinToPostCellBorderColor : UIColor {
        return .red
    }
    
    static func getConfirmationStackColor() -> UIColor{
        return UIColor(red: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1.0)
    }
    
    static var gray1 : UIColor {
        return UIColor(red: 161.0/255, green: 161.0/255, blue: 161.0/255, alpha: 1)
    }
    
    static var gray2 : UIColor {
        return UIColor(red: 151.0/255, green: 151.0/255, blue: 151.0/255, alpha: 1)
    }
    
    static var gray176 : UIColor {
        return UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
    }
    
    static var black35 : UIColor {
        return UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
    }
    
    static var black44 : UIColor {
        return UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1)
    }
}

public struct AppliedCornerRadius {
    public static let standardCornerRadius : CGFloat = 6.0
}

public struct BorderWidths {
    public static let standardBorderWidth : CGFloat = 1.0
    public static let votedOptionBorderWidth : CGFloat = 1.5
}

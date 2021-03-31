//
//  UIDevice+Extension.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public enum DeviceTypes : String {
    case simulator      = "Simulator",
    iPad2          = "iPad 2",
    iPad3          = "iPad 3",
    iPhone4        = "iPhone 4",
    iPhone4S       = "iPhone 4S",
    iPhone5        = "iPhone 5",
    iPhone5S       = "iPhone 5S",
    iPhone5c       = "iPhone 5c",
    iPad4          = "iPad 4",
    iPadMini1      = "iPad Mini 1",
    iPadMini2      = "iPad Mini 2",
    iPadAir1       = "iPad Air 1",
    iPadAir2       = "iPad Air 2",
    iPhone6        = "iPhone 6",
    iPhone6plus    = "iPhone 6 Plus",
    iPhone6S       = "iPhone 6S",
    iPhone6SPlus   = "iPhone 6S Plus",
    iPhoneSE       = "iPhone SE",
    iPhone7        = "iPhone 7",
    iPhone7Plus    = "iPhone 7 Plus",
    iPhone8        = "iPhone 8",
    iPhone8Plus    = "iPhone 8 Plus",
    iPhoneX        = "iPhone X",
    iPhoneXS       = "iPhone XS",
    iPhoneXSMax    = "iPhone XS Max",
    iPhoneXR       = "iPhone XR",
    iPhone11       = "iPhone 11",
    iPhone11Pro    = "iPhone 11 Pro",
    iPhone11ProMax = "iPhone 11 Pro Max",
    unrecognized   = "?unrecognized?"
}

public extension UIDevice {
    public var deviceType: DeviceTypes {
        
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8, value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        
        var modelMap : [ String : DeviceTypes ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            "iPad2,1"   : .iPad2,          //
            "iPad3,1"   : .iPad3,          // (3rd Generation)
            "iPhone3,1" : .iPhone4,        //
            "iPhone3,2" : .iPhone4,        //
            "iPhone4,1" : .iPhone4S,       //
            "iPhone5,1" : .iPhone5,        // (model A1428, AT&T/Canada)
            "iPhone5,2" : .iPhone5,        // (model A1429, everything else)
            "iPad3,4"   : .iPad4,          // (4th Generation)
            "iPad2,5"   : .iPadMini1,      // (Original)
            "iPhone5,3" : .iPhone5c,       // (model A1456, A1532 | GSM)
            "iPhone5,4" : .iPhone5c,       // (model A1507, A1516, A1526 (China), A1529 | Global)
            "iPhone6,1" : .iPhone5S,       // (model A1433, A1533 | GSM)
            "iPhone6,2" : .iPhone5S,       // (model A1457, A1518, A1528 (China), A1530 | Global)
            "iPad4,1"   : .iPadAir1,       // 5th Generation iPad (iPad Air) - Wifi
            "iPad4,2"   : .iPadAir2,       // 5th Generation iPad (iPad Air) - Cellular
            "iPad4,4"   : .iPadMini2,      // (2nd Generation iPad Mini - Wifi)
            "iPad4,5"   : .iPadMini2,      // (2nd Generation iPad Mini - Cellular)
            "iPhone7,1" : .iPhone6plus,    // All iPhone 6 Plus's
            "iPhone7,2" : .iPhone6,         // All iPhone 6's
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6SPlus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7Plus,
            "iPhone9,4" : .iPhone7Plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,2" : .iPhone8Plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,4" : .iPhone8,
            "iPhone10,5" : .iPhone8Plus,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2":   .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
           "iPhone11,8":   .iPhoneXR,
           "iPhone12,1":    .iPhone11,
           "iPhone12,3": .iPhone11Pro,
           "iPhone12,5":  .iPhone11ProMax
        ]
        if let model = modelMap[identifier] {
            return model
        }
        return DeviceTypes.unrecognized
    }
}

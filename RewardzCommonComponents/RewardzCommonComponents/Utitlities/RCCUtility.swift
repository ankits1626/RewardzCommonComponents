//
//  RCCUtility.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 02/04/21.
//

import Foundation

public class RCCUtility {
    
    static public func getNumberSepartedByComma(number : NSNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.usesGroupingSeparator = false
        let formattedNumber = numberFormatter.string(from: number)!
        return formattedNumber
    }
}

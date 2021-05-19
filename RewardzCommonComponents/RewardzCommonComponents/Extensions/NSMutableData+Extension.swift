//
//  NSMutableData+Extension.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 06/04/21.
//

import Foundation

public extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

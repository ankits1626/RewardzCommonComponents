//
//  Collection+Extension.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import Foundation

public extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array {
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
  func getElement(index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}

//
//  Array+Extension.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 22/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

public extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}

public extension Array {
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func get(index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}

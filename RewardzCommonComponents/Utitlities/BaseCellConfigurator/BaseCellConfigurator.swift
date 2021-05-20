//
//  BaseCellConfigurator.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import UIKit

let UnexpectedCellError = NSError(
    domain: "com.rewardz.CellConfigurator",
    code: 1,
    userInfo: [NSLocalizedDescriptionKey: "Asking configurator to configure unexpected cell."]
)

open class BaseCellConfigurator {
    public init(){}
    public func checkCell<T>(_ cell: UITableViewCell) throws -> T{
        if let expectedCell = cell as? T{
            return expectedCell
        }else{
            throw UnexpectedCellError
        }
    }
}

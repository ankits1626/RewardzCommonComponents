//
//  RawRepresentable.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 20/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
import CoreData

public protocol RawRepresentable {
    func getRawObject() -> RawObjectProtocol
}

public protocol RawObjectProtocol {
    init(input : [String : Any])
    init(managedObject : NSManagedObject)
    func getManagedObject() -> NSManagedObject
}

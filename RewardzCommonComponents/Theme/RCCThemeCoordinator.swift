//
//  RCCThemeCoordinator.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 13/04/21.
//

import UIKit

public protocol RCCThemeCoordinatorProtocol {
    func getBackgroundColor() -> UIColor
}

public class RCCThemeDetailProvider{
    public static let shared : RCCThemeDetailProvider = RCCThemeDetailProvider()
    public var coordinator: RCCThemeCoordinatorProtocol! = nil
}

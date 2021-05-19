//
//  CFFThemeManagerProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit Sachan on 19/08/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public protocol CFFThemeManagerProtocol : class {
    func getThemeSpecificImage(_ imageName : String) -> UIImage?
    func getControlActiveColor() -> UIColor
    func getStepperActiveColor() -> UIColor
    func getHeaderFont() -> UIFont
}

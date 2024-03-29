//
//  CFFMediaCoordinatorProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public protocol CFFMediaCoordinatorProtocol : class {
    func fetchImageAndLoad(_ targetView : UIImageView? , imageEndPoint : String)
    func fetchImageAndLoad(_ targetView : UIImageView? , imageEndPoint : URL?)
    func fetchImageAndLoad(_ targetView : UIImageView? , imageWithCompleteURL : String)
}

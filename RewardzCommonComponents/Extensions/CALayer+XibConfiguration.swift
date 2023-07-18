//
//  CALayer+XibConfiguration.swift
//  SKOR
//
//  Created by Rewardz on 13/06/19.
//  Copyright © 2019 Rewradz Private Limited. All rights reserved.
//

import UIKit
public extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}

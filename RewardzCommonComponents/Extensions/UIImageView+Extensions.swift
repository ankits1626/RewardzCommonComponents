//
//  UIImageView+Extensions.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 02/04/21.
//

import UIKit

public extension UIImageView {
    
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
    
}

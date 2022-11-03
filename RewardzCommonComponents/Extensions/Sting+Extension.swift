//
//  Sting+Extension.swift
//  RewardzCommonComponents
//
//  Created by Ankit on 31/10/22.
//

import Foundation

public extension String{
    func pluralize(_ count : Int) -> Self {
        if count == 1{
            return self
        }else{
            return "\(self)s"
        }
    }
}

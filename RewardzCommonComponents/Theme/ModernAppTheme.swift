//
//  ModernAppTheme.swift
//  RewardzCommonComponents
//
//  Created by Ankit on 13/03/23.
//

import UIKit

public extension UIFont{
    static var sf32Bold : UIFont{
        return UIFont.systemFont(ofSize: 32, weight: .bold)
    }
    
    static var sf16Regular : UIFont{
        return UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    static var sf16Medium : UIFont{
        return UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    static var sf14Medium : UIFont{
        return UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    static var sf14Regular : UIFont{
        return UIFont.systemFont(ofSize: 14, weight: .regular)
    }
}


public extension UIColor{
    static var headerColor : UIColor{
        return .black
    }
    
    static var subHeaderColor : UIColor{
        return UIColor(red: 171, green: 173, blue: 192)
    }
    
    static var controlTextColor : UIColor{
        return .white
    }
}

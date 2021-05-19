//
//  ThemeableViewControllerProtcol.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 03/04/21.
//

import UIKit

public protocol ThemeableViewControllerProtcol : class {
    var navigationColor: UIImageView?{get set}
    var headerColor: UIImageView? {get set}
    var searchTextField: UITextField! {get set}
    func applyTheme(colorBool : Bool)
    func invertedSearchBarTheme()
}

public extension ThemeableViewControllerProtcol{
    func invertedSearchBarTheme(){
        self.headerColor?.backgroundColor = .getBackgroundGreyColor()
        if searchTextField != nil{
            searchTextField.applyInvertedSearchTheme()
        }
    }
    func applyTheme(colorBool : Bool){
        if colorBool
        {
            self.navigationColor?.image = UIImage(named: "")
            self.navigationColor?.backgroundColor = .getHeaderColor()
            self.headerColor?.image = UIImage(named: "")
            self.headerColor?.backgroundColor = .getHeaderColor()
        }
        applyThemeToSearchTextField()
    }
    
    private func applyThemeToSearchTextField(){
        if searchTextField != nil{
            searchTextField.applySearchTheme()
        }
    }
}


//
//  SearchEnabledViewControllerProtcol.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 03/04/21.
//

import UIKit

public protocol SearchEnabledViewControllerProtcol : class {
    var searchTextField: UITextField! {get set}
    func configureSearchTextField()
}

public extension SearchEnabledViewControllerProtcol{
    func configureSearchTextField(){
        searchTextField.applySearchTheme()
    }
}

extension UITextField{
    func applySearchTheme() {
        self.backgroundColor = UIColor.getBackgroundGreyColor()
        self.background = UIImage(named: "")
        self.attributedPlaceholder = NSAttributedString(string:"  \(NSLocalizedString("Search", comment: ""))", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        //self.searchTextField.backgroundColor = Rgbconverter.HexToColor("#FFFFFF", alpha: 0.4)
        self.borderStyle = .none
        let imageView = UIImageView(image: UIImage(named: "rc_searchIcon"))
        imageView.contentMode = UIView.ContentMode.center
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageView.image!.size.width + 20.0, height: imageView.image!.size.height)
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: imageView.image!.size.height))
        leftView.backgroundColor = .clear
        leftView.addSubview(imageView)
        self.leftViewMode = UITextField.ViewMode.always
        self.leftView = leftView
        textColor = .white
        self.curvedCornerControl()
    }
    
    func applyInvertedSearchTheme() {
        self.backgroundColor = UIColor.white
        self.background = UIImage(named: "")
        self.attributedPlaceholder = NSAttributedString(string:"  \(NSLocalizedString("Search", comment: ""))", attributes:[NSAttributedString.Key.foregroundColor: UIColor.getBackgroundGreyColor()])
        //self.searchTextField.backgroundColor = Rgbconverter.HexToColor("#FFFFFF", alpha: 0.4)
        self.borderStyle = .none
        let imageView = UIImageView(image: UIImage(named: "searchnewicon"))
        imageView.contentMode = UIView.ContentMode.center
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageView.image!.size.width + 20.0, height: imageView.image!.size.height)
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: imageView.image!.size.height))
        leftView.backgroundColor = .clear
        leftView.addSubview(imageView)
        self.leftViewMode = UITextField.ViewMode.always
        self.leftView = leftView
        textColor = .black
        self.curvedCornerControl()
    }
}

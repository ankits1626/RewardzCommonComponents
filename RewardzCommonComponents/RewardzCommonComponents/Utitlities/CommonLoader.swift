//
//  CommonLoader.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 24/09/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public class CommonLoader {
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    public init(){}
    
    public func showActivityIndicator(_ uiView: UIView) {
        DispatchQueue.main.async {
            self.show(uiView)
        }
    }
    
    private func show(_ uiView: UIView)  {
        uiView.frame = UIScreen.main.bounds
        self.container.frame = uiView.frame
        self.container.center = uiView.center
        self.container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0)
        self.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.loadingView.center = uiView.center
        self.loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        self.loadingView.clipsToBounds = true
        self.loadingView.layer.cornerRadius = 10
        self.activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        self.loadingView.addSubview(activityIndicator)
        self.container.addSubview(loadingView)
        uiView.addSubview(container)
        self.activityIndicator.startAnimating()
    }

    public func hideActivityIndicator(_ uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }

    public func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

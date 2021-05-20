//
//  ErrorDisplayer.swift
//  RewardzWeightReader
//
//  Created by Rewardz on 24/04/17.
//  Copyright © 2017 Rewardz Private Limited. All rights reserved.
//

import UIKit

public class ErrorDisplayer: NSObject {

    public static func showError (errorMsg : String, okActionHandler: @escaping (UIAlertAction)->()){
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let alertVC = UIAlertController(title: "", message: errorMsg, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: okActionHandler)
            alertVC.addAction(okAction)
            topController.present(alertVC, animated: true, completion: nil)
            // topController should now be your topmost view controller
        }
    }
}

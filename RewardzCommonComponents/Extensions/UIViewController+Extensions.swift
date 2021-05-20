//
//  UIViewController+Extensions.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import UIKit

public extension UIViewController {
    func showAlert(title: String = "", message: String = "", handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK".localized, style: .cancel, handler: handler)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true)
        }
    }
    
    func showAlert(title: String = "", message: String = "", okHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler:  ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: okHandler)
            alertView.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: cancelHandler)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true)
        }
    }
    
    func showSubmitAlert(title: String = "", message: String = "", submitHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler:  ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let submitAction = UIAlertAction(title: "Submit".localized, style: .default, handler: submitHandler)
            alertView.addAction(submitAction)
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: cancelHandler)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true)
        }
    }
    
    func showAlertWithoutCancel(title: String = "", message: String = "", okHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler:  ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: okHandler)
            alertView.addAction(okAction)
            self.present(alertView, animated: true)
        }
    }
    
    func showToast(message : String) {
        var bottomSafeArea : CGFloat!
        if #available(iOS 11.0, *) {
            bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        }else{
            bottomSafeArea = 0.0
        }
        let toastLabel = UILabel(frame: CGRect(x: 15, y: self.view.frame.size.height-100 - bottomSafeArea, width: self.view.bounds.width - 30, height: 60))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }) { (isCompleted) in
            toastLabel.removeFromSuperview()
        }
    }
}



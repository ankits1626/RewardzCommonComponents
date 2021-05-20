//
//  NoEntryFoundViewViewController.swift
//  Cerrapoints SG
//
//  Created by Rewardz on 23/11/19.
//  Copyright © 2019 Rewradz Private Limited. All rights reserved.
//

import UIKit

public class NoEntryFoundViewViewController: UIViewController {
    @IBOutlet weak var messageLabel : UILabel?
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func showEmptyMessageView(message: String, parentView: UIView, parentViewController: UIViewController) {
        messageLabel?.text = message
        parentViewController.addChild(self)
        view.frame = CGRect(
            x: 0,
            y: 0,
            width: parentView.bounds.size.width,
            height: parentView.bounds.size.height
        )
        parentView.addSubview(view)
        didMove(toParent: parentViewController)
    }
    
    public func hideEmptyMessageView() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

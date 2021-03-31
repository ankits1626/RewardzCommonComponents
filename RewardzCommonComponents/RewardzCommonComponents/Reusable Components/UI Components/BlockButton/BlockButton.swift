//
//  BlockButton.swift
//  SKOR
//
//  Created by Rewardz on 13/03/19.
//  Copyright © 2019 Rewradz Private Limited. All rights reserved.
//

import UIKit


public class BlockButton: UIButton {
    private var _actionBlock : (() -> Void)?
    public func handleControlEvent(event:UIControl.Event, buttonActionBlock:(() -> Void)?)  {
        _actionBlock = buttonActionBlock
        self.removeTarget(nil, action: nil, for: event)
        self.addTarget(self, action: #selector(callActionBlock(sender:)), for: event)
    }
    
    @objc func callActionBlock(sender:BlockButton)  {
        _actionBlock!()
    }
}

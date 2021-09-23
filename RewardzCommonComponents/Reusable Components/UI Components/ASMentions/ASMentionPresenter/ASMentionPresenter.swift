//
//  ASMentionPresenter.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 09/12/20.
//

import UIKit

class ASMentionPresenter {
    static let shared = ASMentionPresenter()
    
    func updatePresentationOfText(text : NSAttributedString?, mentions: [ASMentionEntityProtocol]?) -> NSAttributedString? {
        if let unwrappedText = text?.string{
            let processedString : NSMutableAttributedString = NSMutableAttributedString(string: unwrappedText)
            let attributes : [NSAttributedString.Key: Any] = [
                .font : UIFont.SemiBold14,
                .foregroundColor : UIColor.black
            ]
            mentions?.forEach({ (aMention) in
                processedString.addAttributes(attributes, range: aMention.range)
            })
            return processedString
        }else{
            return nil
        }
    }
}

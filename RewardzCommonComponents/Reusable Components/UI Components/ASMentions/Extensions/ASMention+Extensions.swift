//
//  ASMention+Extensions.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 11/12/20.
//

import UIKit


extension UITextView{
    func textRangeFromNSRange(range:NSRange) -> UITextRange?
    {
        let beginning = self.beginningOfDocument
        guard let start = position(from: beginning, offset: range.location),
              let end = position(from: start, offset: range.length)
        else { return nil}
        
        return textRange(from: start, to: end)
    }
}


extension String {
    func index(from: Int) -> Index {
        return self.utf16.index(utf16.startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

extension NSAttributedString{
    static func getTagText( input : String) -> NSAttributedString {
        let attributes : [NSAttributedString.Key: Any] = [
            .font : UIFont.systemFont(ofSize: 72),
            .foregroundColor : UIColor.blue
        ]
        return NSAttributedString(string: input, attributes: attributes)
    }
    
    static func getNormalText( input : String) -> NSAttributedString {
        let attributes : [NSAttributedString.Key: Any] = [
            .font : UIFont.systemFont(ofSize: 10),
            .foregroundColor : UIColor.black
        ]
        return NSAttributedString(string: input, attributes: attributes)
    }
}


extension RangeExpression where Bound == String.Index  {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}

extension String{
    struct LastTagOccurence {
        var tag: String
        var tagRange : NSRange
        
    }
    
    func lastTagOccurence(_ sb : String) -> LastTagOccurence? {
        if let position =  self.rangeOfCharacter(from: CharacterSet(charactersIn: sb), options: .backwards, range: nil){
            let l = position.nsRange(in: self).location
            let sub = substring(from: position.lowerBound)
            return LastTagOccurence(tag: sub, tagRange: NSMakeRange(l, sub.count))
        }else{
            return nil
        }
    }
}

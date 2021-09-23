//
//  ASMentionText.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 06/12/20.
//

import UIKit

protocol ASMentionEntityProtocol {
    var displayName: String { get }
    var id : Int { get }
    var range : NSRange {get}
    var email : String {get}
    
    func getPostableMention() -> String
    func updateRange(_ newRange: NSRange)
}

class ASMention : ASMentionEntityProtocol{
    var displayName: String
    var id : Int
    var range : NSRange
    let email : String
    
    static let DisplayTagName = "display_name"
    static let UidTagName = "pk"
    static let EmailTagName = "email_id"
    static let StartIndexTagName = "start_index"
    static let EndIndexTagName = "end_index"
    
    init(_ raw : String, startPosition : Int) {
        self.displayName = ASMention.getValue(raw: raw, tagName: ASMention.DisplayTagName)
        self.id = Int(ASMention.getValue(raw: raw, tagName: ASMention.UidTagName)) ?? -1
        self.range = NSMakeRange(startPosition, displayName.count)
        self.email = ASMention.getValue(raw: raw, tagName: ASMention.EmailTagName)
    }
    
    static func getValue(raw: String, tagName: String) -> String{
        let parts = raw.components(separatedBy: "</\(tagName)>")
        return parts[0].components(separatedBy: "<\(tagName)>").last ?? "debug \(tagName)"
    }
    
    func getPostableMention() -> String {
        return [
            "<tag>",
            getPostableMentionProperty(ASMention.UidTagName, value: id),
            getPostableMentionProperty(ASMention.DisplayTagName, value: displayName),
            getPostableMentionProperty(ASMention.StartIndexTagName, value: range.location),
            getPostableMentionProperty(ASMention.EndIndexTagName, value: range.location + range.length),
            "</tag>"
        ].joined(separator: "")
    }
    
    private func getPostableMentionProperty(_ propertyName: String, value: Any) -> String{
        return "<\(propertyName)>\(value)</\(propertyName)>"
    }
    
    func updateRange(_ newRange: NSRange) {
        let old = range
        self.range = newRange
        print("<<<<<< updated \(displayName) from \(old) to \(newRange)")
    }
        
}



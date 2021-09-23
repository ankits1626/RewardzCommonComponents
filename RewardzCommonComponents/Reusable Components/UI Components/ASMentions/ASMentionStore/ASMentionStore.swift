//
//  ASMentionStore.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 09/12/20.
//

import Foundation

class ASMentionStore {
    static let shared = ASMentionStore()
    public private(set) var mentions : [ASMentionEntityProtocol]!{
        didSet{
            print("********** updated count \(mentions.map({ (m) -> String in return m.displayName }))")
        }
    }
    
    
    func updateStoreAfterTextLoad(_ mentions: [ASMentionEntityProtocol]?) {
        self.mentions = mentions
    }
    
    func clearAllMentions() {
        mentions.removeAll()
    }
    
    func updateStoreAfterTextDeletion(_ deletionRange: NSRange) {
        mentions.forEach { (aMention) in
            if deletionRange.location < aMention.range.location{
                aMention.updateRange(NSMakeRange(aMention.range.location - deletionRange.length, aMention.range.length))
            }
        }
    }
    
    func updateStoreAfterTextAddition(_ additionRange: NSRange) {
        mentions.forEach { (aMention) in
            if additionRange.location <= aMention.range.location{
                aMention.updateRange(NSMakeRange(aMention.range.location + additionRange.length, aMention.range.length))
            }
        }
    }
    
    func updateStoreAfterTextReplacement(_ replacementRange : NSRange, replacementTextLength: Int) {
        mentions.forEach { (aMention) in
            if replacementRange.location <= aMention.range.location{
                aMention.updateRange(NSMakeRange(aMention.range.location + (replacementTextLength - replacementRange.length), aMention.range.length))
            }
        }
    }
    
    func clearIntersectingMentions(_ range: NSRange) -> [ASMentionEntityProtocol]? {
        let clearedMention =  mentions.filter { (aMention) -> Bool in
            return NSIntersectionRange(aMention.range, range).length > 0
        }.sorted { (a, b) -> Bool in
            return a.range.location < b.range.location
        }
        
        mentions = mentions.filter({ (aMention) -> Bool in
            return NSIntersectionRange(aMention.range, range).length == 0
        })
        
        return clearedMention
    }
    
    func updateStorAfterNewMention(_ newMention: ASMentionEntityProtocol, offset: Int) {
        updateStoreAfterTextAddition(NSMakeRange(newMention.range.location, newMention.range.length - offset))
        mentions.append(newMention)
    }
    
}

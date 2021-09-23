//
//  ASMentionTextParser.swift
//  MentionsPOC
//
//  Created by Ankit Sachan on 06/12/20.
//

import Foundation

class ASMentionTextParser{
    static let shared = ASMentionTextParser()
    
    func parse(_ originalText : String, completion:((_ mentions : [ASMentionEntityProtocol], _ presentableText: String?) -> Void)){
        var mentions = [ASMentionEntityProtocol]()
        let parts = originalText.components(separatedBy: "</tag>")
        var presentableString : String = ""
        for part in parts{
            if part.contains("<tag>"){
                let sub = part.components(separatedBy: "<tag>")
                for s in sub{
                    if s.contains("pk"){
                        let mention = ASMention(s, startPosition: presentableString.utf16.count)
                        mentions.append(mention)
                        presentableString.append(mention.displayName)
                    }else{
                        presentableString.append(s)
                    }
                }
            }else{
                presentableString.append(part)
            }
        }
        completion(mentions, presentableString)
    }
}

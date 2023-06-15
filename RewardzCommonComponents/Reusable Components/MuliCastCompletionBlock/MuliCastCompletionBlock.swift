//
//  MuliCastCompletionBlock.swift
//  RewardzCommonComponents
//
//  Created by Ankit on 02/04/23.
//

import Foundation

struct MulticastCompletionBlockWrapper<T>{
    weak var observer :  AnyObject?
    var completionBlock : ((T)->Void)
}

/**
 Multi caast completion blocks execute completion blocks of multiple observers
 */

public class MulticastCompletionBlock<T>{
    private var blocks = [ObjectIdentifier : MulticastCompletionBlockWrapper<T>]()
    
    public init(){}
    
    public func execute(_ props : T){
        for (id, wrapper) in blocks{
            guard let _ = wrapper.observer else{
                blocks.removeValue(forKey: id)
                continue
            }
            wrapper.completionBlock(props)
        }
    }
    
    public func addObserver(_ observer: AnyObject, completionBlock:@escaping ((T) -> Void)){
        let id  = ObjectIdentifier(observer)
        blocks[id] = MulticastCompletionBlockWrapper(observer: observer, completionBlock: completionBlock)
    }
    
    public func removeObserver(_ observer: AnyObject){
        let id  = ObjectIdentifier(observer)
        blocks.removeValue(forKey: id)
    }
}

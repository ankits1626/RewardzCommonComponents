//
//  RCCAnalytics.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 23/11/21.
//

import Foundation

public enum RCCAnalyticsEvent : String{
    case Reward = "reward_id"
    case Event = "event_id"
    case Announcement = "announc_id"
}

public enum RCCAnalyticsAttribute : String{
    case name = "name"
    case id = "id"
}

public protocol RCCAnalyticsItemProtocol : AnyObject{
    var analyticsInfo : [RCCAnalyticsAttribute : Any]? { set get }
    var event :RCCAnalyticsEvent { get }
}

public protocol RCCAnalyticsAggregatorProtocol{
    
    func logEvent(info : RCCAnalyticsItemProtocol)
    
}

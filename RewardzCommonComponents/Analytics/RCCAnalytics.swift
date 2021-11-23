//
//  RCCAnalytics.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 23/11/21.
//

import Foundation

public enum RCCAnalyticsEvent : String{
    case Reward = "screen_reward_detail"
    case Event = "screen_event_detail"
    case Announcement = "screen_announcement_detail"
}

public enum RCCAnalyticsAttribute : String{
    case name = "name"
    case id = "id"
}

public protocol RCCAnalyticsItemProtocol : AnyObject{
    var analyticsInfo : [RCCAnalyticsAttribute : Any]? { set get }
    var event :RCCAnalyticsEvent { get }
}

public protocol CFFAnalyticsAggregatorProtocol{
    
    func logEvent(info : RCCAnalyticsItemProtocol)
    
}

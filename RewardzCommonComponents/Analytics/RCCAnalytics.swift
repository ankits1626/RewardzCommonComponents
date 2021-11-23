//
//  RCCAnalytics.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 23/11/21.
//

import Foundation

public enum CFFAnalyticsEvent : String{
    case Reward = "screen_reward_detail"
    case Event = "screen_event_detail"
    case Announcement = "screen_announcement_detail"
}

public enum CFFAnalyticsAttribute : String{
    case name = "name"
    case id = "id"
}

public protocol CFFAnalyticsItemProtocol : AnyObject{
    var analyticsInfo : [CFFAnalyticsAttribute : Any]? { set get }
    var event :CFFAnalyticsEvent { get }
}

public protocol CFFAnalyticsAggregatorProtocol{
    
    func logEvent(info : CFFAnalyticsItemProtocol)
    
}

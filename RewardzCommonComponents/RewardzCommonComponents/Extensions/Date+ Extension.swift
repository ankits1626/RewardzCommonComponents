//
//  Date+ Extension.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

public extension Date
{
    func hour() -> Int
    {
        //Get Hour
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([Calendar.Component.hour], from: self) //calendar.components(NSCalendar.Unit.Hour, fromDate: self)
        if let hour = components.hour{
            return hour
        }
        
        //Return Hour
        return 0
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([Calendar.Component.minute], from: self) //calendar.components(NSCalendar.Unit.Minute, fromDate: self)
        if let minute = components.minute{
            return minute
        }
        
        //Return Minute
        return 0
    }
    
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeStyle = .short
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString
    }
}

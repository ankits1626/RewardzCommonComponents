//
//  CommonFrameworkUtility.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
public class CommonFrameworkDateUtility {
    public static func getDateFromStringFrom(_ date : String, dateFormat: String) -> Date?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let strDate = dateFormatter.date(from: date)
        {
            return strDate
        }
        return nil
    }
    
    public static func getDisplayedDateInFormatDMMMYYYY(input: String, dateFormat : String) -> String?{
        let dateFormatter = getDateFormatter(dateFormat: dateFormat)
        let date = dateFormatter.date(from:input)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        dateFormatter.dateFormat = "d MMM yyyy"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: calendar.date(from:components)!)
    }
    public static func getCurrentDateInFormatDMMMYYYY(dateFormat : String) -> String?{
        
        let dateFormatter = getDateFormatter(dateFormat: dateFormat)
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        dateFormatter.dateFormat = "d MMM yyyy"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: calendar.date(from:components)!)
    }
    
    public static func getDisplayedDateInFormatMMMYYYY(input: String, dateFormat : String) -> String?{
        let dateFormatter = getDateFormatter(dateFormat: dateFormat)
        let date = dateFormatter.date(from:input)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        dateFormatter.dateFormat = "MMM yyyy"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: calendar.date(from:components)!)
    }
    
    public static func getDisplayedDateInFormatMMMDD(input: String, dateFormat : String) -> String?{
        let dateFormatter = getDateFormatter(dateFormat: dateFormat)
        let date = dateFormatter.date(from:input)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        dateFormatter.dateFormat = "MMM dd"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: calendar.date(from:components)!)
    }
    
    public static func getDateFormatter (dateFormat : String) -> DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }
    
    public static func getDisplayableDate(input: String, dateFormat : String) -> String?{
        let dateFormatter = getDateFormatter(dateFormat: dateFormat)
        let date = dateFormatter.date(from:input)!
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date){
            let components = calendar.dateComponents([.hour, .minute], from: date)
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            return dateFormatter.string(from: calendar.date(from:components)!)
        }else{
            return getDisplayedDateInFormatDMMMYYYY(input: input, dateFormat: dateFormat)
        }
    }
    
    public static  func getDaysDifferenceBetweenTwoDates(from: Date, to : Date) -> Int{
        return Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
    }
}

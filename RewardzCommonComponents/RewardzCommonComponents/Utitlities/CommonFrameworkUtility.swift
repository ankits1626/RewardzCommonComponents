//
//  CommonFrameworkUtility.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
class CommonFrameworkDateUtilityDup {
    static func getDateFromStringFrom(_ date : String, dateFormat: String) -> Date?
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
    
    static func getDisplayableDate(input: String) -> String?{
        return nil
    }
}

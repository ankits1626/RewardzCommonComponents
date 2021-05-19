//
//  Date+Extensions.swift
//  RewardzCommonComponents
//
//  Created by Ankit Sachan on 01/04/21.
//

import Foundation

public enum Weekday: Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

public extension Date {
    
    var monthName: String {
        
        let month = self.month
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.monthSymbols[month-1]
    }
    
    var weekDayname: String {
        
        let week = self.day
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.weekdaySymbols[week-1]
    }
    
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.string(from: self).capitalized
        
        // or capitalized(with: locale)
    }

    var year:   Int { return Calendar(identifier: .gregorian).component(.year,   from: self as Date) }
    var month:  Int { return Calendar(identifier: .gregorian).component(.month,  from: self as Date) }
    var day:    Int { return Calendar(identifier: .gregorian).component(.day,    from: self as Date) }
    
    func dateByAddingUnit(unit: Calendar.Component, value: Int) -> Date? {
        return Calendar.current.date(byAdding: unit, value: value, to: self)
        
    }
    var today: Date {
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
        //return Calendar.gregorian.dateFromComponents(DateComponents(year: year, month: month, day: day))!
    }
    var tomorrow: Date {
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day+1))!
        //return Calendar.gregorian.dateFromComponents(DateComponents(year: year, month: month, day: day+1))!
    }
    var sevenDays:[Date] {
        var result:[Date] = [Date().today.dateByAddingUnit(unit: .day, value: -3)!]
        for _ in 1...6 {
            result.append(result.last!.tomorrow)
        }
        return result
    }
    var sevenDaysOfWeek:[Date] {
        //var result:[Date] = [Date().today.dateByAddingUnit(unit: .day, value: -5, options: NSCalendar.Options())]
        var result:[Date] = [Date().today.dateByAddingUnit(unit: .day, value: -5)!]
        for _ in 1...6 {
            result.append(result.last!.tomorrow)
        }
        return result
    }
    var sevenDaysForHistory:[Date] {
        var result:[Date] = [Date().today.dateByAddingUnit(unit: .day, value: -2)!]
        for _ in 1...6 {
            result.append(result.last!.tomorrow)
        }
        return result
    }
    var sevenMonths:[Int] {
        var result:[Date] = [Date().today.dateByAddingUnit(unit: .month, value: -2)!]
        for _ in 1...6 {
            result.append(result.last!.dateByAddingUnit(unit: .month, value: 1)!)
        }
        return result.map{$0.month}
    }
    var sevenMonthsNames:[String] {
        var result:[Date] = [Date().today.dateByAddingUnit(unit: .month, value: -2)!]
        for _ in 1...6 {
            result.append(result.last!.dateByAddingUnit(unit: .month, value: 1)!)
        }
        return result.map{$0.monthName}
    }
    var sevenMonthsNameswithDate:[Date] {
        var result:[Date] = [Date().today.dateByAddingUnit(unit: .month, value: -2)!]
        for _ in 1...6 {
            result.append(result.last!.dateByAddingUnit(unit: .month, value: 1)!)
        }
        return result.map{$0}
    }
    func following(weekday: Weekday) -> Date {
        var components = DateComponents()
        components.weekday = weekday.rawValue
        guard
            let date = Calendar.current.nextDate(after: self, matching: components, matchingPolicy: .nextTime)// Calendar.gregorian.nextDateAfterDate(self, matchingComponents: components, options: .MatchNextTime)
            else { return Date.distantFuture }
        return  date
    }
    var currentWeekFirstDate: Date {
        return following(weekday: .Sunday).dateByAddingUnit(unit: .weekOfYear, value: -1)!
    }
    var currentWeekDates:[Date] {
        var result:[Date] = [Date().today.currentWeekFirstDate]
        for _ in 1...6 {
            result.append(result.last!.tomorrow)
        }
        return result
    }
    var currentWeekDays:[Int] {
        return currentWeekDates.map{$0.day}
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}

public extension Date {
    
    init?(dateString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.locale = Locale(identifier: "en_US")
        dateStringFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss Z"
        dateStringFormatter.calendar = Calendar(identifier: .gregorian)
        dateStringFormatter.timeZone = TimeZone(identifier: "GMT")
        if let date = dateStringFormatter.date(from: dateString){
            self = date
        }else{
            return nil
        }
    }
    
    func getDatePart() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "GMT + 5:30")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.string(from: self as Date)
    }
    
    func getTimePart() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "hh : mm"
        formatter.timeZone = TimeZone(identifier: "GMT + 5:30")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.string(from: self as Date)
    }
}

public extension Date {
  func dateWithOutTime() -> Date {
    let comps = Calendar.current.dateComponents([.day, .month, .year], from: self)
    return NSCalendar.current.date(from: comps)!
  }

  func isBetweeen(startDate date1: Date, endDate date2: Date) -> Bool {
    return date1.compare(self as Date) == self.compare(date2 as Date)
  }
}

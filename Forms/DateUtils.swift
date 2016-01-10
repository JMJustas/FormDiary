//
//  DateExtension.swift
//  Forms
//
//  Created by Justinas Marcinka on 18/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

extension NSDate {
    func isBefore(date: NSDate) -> Bool {
        return self.timeIntervalSinceDate(date) < 0
    }
    
    func isAfter(date: NSDate) -> Bool {
        return self.timeIntervalSinceDate(date) > 0
    }
    
}

extension Int {
    var day: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Day)
    }
    
    var month: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Month)
    }
    
    var year: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Year)
    }
}

////
public func + (date: NSDate, tuple: (value: Int, unit: NSCalendarUnit)) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingUnit(tuple.unit, value: tuple.value, toDate: date, options: .MatchFirst)!
}

public func - (date: NSDate, tuple: (value: Int, unit: NSCalendarUnit)) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingUnit(tuple.unit, value: (-tuple.value), toDate: date, options:.MatchFirst)!
}

public func += (inout date: NSDate, tuple: (value: Int, unit: NSCalendarUnit)) {
    date =  NSCalendar.currentCalendar().dateByAddingUnit(tuple.unit, value: tuple.value, toDate: date, options:.MatchFirst)!
}

public func -= (inout date: NSDate, tuple: (value: Int, unit: NSCalendarUnit)) {
    date =  NSCalendar.currentCalendar().dateByAddingUnit(tuple.unit, value: -tuple.value, toDate: date, options:.MatchFirst)!
}
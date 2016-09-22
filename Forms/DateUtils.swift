//
//  DateExtension.swift
//  Forms
//
//  Created by Justinas Marcinka on 18/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

extension Date {
    func isBefore(_ date: Date) -> Bool {
        return self.timeIntervalSince(date) < 0
    }
    
    func isAfter(_ date: Date) -> Bool {
        return self.timeIntervalSince(date) > 0
    }
    
}

extension Int {
    var day: (Int, NSCalendar.Unit) {
        return (self, NSCalendar.Unit.day)
    }
    
    var month: (Int, NSCalendar.Unit) {
        return (self, NSCalendar.Unit.month)
    }
    
    var year: (Int, NSCalendar.Unit) {
        return (self, NSCalendar.Unit.year)
    }
}

////
public func + (date: Date, tuple: (value: Int, unit: NSCalendar.Unit)) -> Date {
    return (Calendar.current as NSCalendar).date(byAdding: tuple.unit, value: tuple.value, to: date, options: .matchFirst)!
}

public func - (date: Date, tuple: (value: Int, unit: NSCalendar.Unit)) -> Date {
    return (Calendar.current as NSCalendar).date(byAdding: tuple.unit, value: (-tuple.value), to: date, options:.matchFirst)!
}

public func += (date: inout Date, tuple: (value: Int, unit: NSCalendar.Unit)) {
    date =  (Calendar.current as NSCalendar).date(byAdding: tuple.unit, value: tuple.value, to: date, options:.matchFirst)!
}

public func -= (date: inout Date, tuple: (value: Int, unit: NSCalendar.Unit)) {
    date =  (Calendar.current as NSCalendar).date(byAdding: tuple.unit, value: -tuple.value, to: date, options:.matchFirst)!
}

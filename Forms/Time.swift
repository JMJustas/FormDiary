//
//  Time.swift
//  Forms
//
//  Created by Justinas Marcinka on 09/05/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation

class Time: CustomStringConvertible {
    var hour:Int
    var minute: Int
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    init (timestamp: String) {
        var tokens = timestamp.characters.split{$0 == ":"}
        hour = Int(String(tokens[0]))!
        minute = Int(String(tokens[1]))!
    }
    
    init (date: NSDate) {
        hour = calendar.component(.Hour, fromDate: date)
        minute = calendar.component(.Minute, fromDate: date)
    }
    
    func toTodaysDate() -> NSDate {
        let components = NSDateComponents()
        components.hour = self.hour
        components.minute = self.minute
        return calendar.dateFromComponents(components)!
    }
    
    var description: String {
        return "\(hour):\(minute)"
    }
}

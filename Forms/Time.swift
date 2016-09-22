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
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)

    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    init (timestamp: String) {
        var tokens = timestamp.characters.split{$0 == ":"}
        hour = Int(String(tokens[0]))!
        minute = Int(String(tokens[1]))!
    }
    
    init (date: Date) {
        hour = (calendar as NSCalendar).component(.hour, from: date)
        minute = (calendar as NSCalendar).component(.minute, from: date)
    }
    
    func toTodaysDate() -> Date {
        var components = DateComponents()
        components.hour = self.hour
        components.minute = self.minute
        return calendar.date(from: components)!
    }
    
    var description: String {
        return "\(hour):\(minute)"
    }
}

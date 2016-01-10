//
//  NotificationTime.swift
//  Forms
//
//  Created by Justinas Marcinka on 01/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

class NotificationTime : CustomStringConvertible{
    var hour: Int = 9;
    var minute: Int = 0;
    var dayOfWeek: String = "ad"; //stands for "all days"
    
//    Should use time of format HH:mm:dayOfWeek
//    dayOfWeek: wd- working days, we - weekends
    
    //TODO throw exception if invalid input
    init (timestamp:String) throws {
        var tokens = timestamp.characters.split{$0 == ":"};
        hour = Int(String(tokens[0]))!;
        minute = Int(String(tokens[1]))!;
        dayOfWeek = String(tokens[2]);
    }
    
    var description: String {
        return "\(hour):\(minute):\(dayOfWeek)"
    }

}
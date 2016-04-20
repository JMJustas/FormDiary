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
    
    init (timestamp:String) throws {
        if timestamp == "bw" {
            dayOfWeek = "wd";
            if let time = NSUserDefaults.standardUserDefaults().stringForKey("beforeWorkTime") {
                var tokens = time.characters.split{$0 == ":"}
                hour = Int(String(tokens[0]))!
                minute = Int(String(tokens[1]))!
            } else {
                hour = 9
                minute = 0
            }
            return
        }
        
        if timestamp == "aw" {
            dayOfWeek = "wd";
            if let time = NSUserDefaults.standardUserDefaults().stringForKey("beforeWorkTime") {
                var tokens = time.characters.split{$0 == ":"}
                hour = Int(String(tokens[0]))!
                minute = Int(String(tokens[1]))!
            } else {
                hour = 18
                minute = 0
            }
            return
        }

        
        var tokens = timestamp.characters.split{$0 == ":"};
        hour = Int(String(tokens[0]))!;
        minute = Int(String(tokens[1]))!;
        dayOfWeek = String(tokens[2]);
    }
    
    var description: String {
        return "\(hour):\(minute):\(dayOfWeek)"
    }

}
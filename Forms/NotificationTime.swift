//
//  NotificationTime.swift
//  Forms
//
//  Created by Justinas Marcinka on 01/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

class NotificationTime : CustomStringConvertible {
    var _hour: Int
    var _minute: Int
    
    var hour: Int {
        get { return getHour() }
    }
    var minute: Int {
        get { return getMinute() }
    };
    var dayOfWeek: String = "ad"; //stands for "all days"
    let settingsService = SettingsService.instance
    
//    Should use time of format HH:mm:dayOfWeek
//    dayOfWeek: wd- working days, we - weekends
//
    init (timestamp:String) {
        NSLog("constructing from: \(timestamp)")
        if timestamp == "bw" || timestamp == "aw" {
            self.dayOfWeek = timestamp
            _hour = 0
            _minute = 0
            return
        }
        
        var tokens = timestamp.characters.split{$0 == ":"};
        _hour = Int(String(tokens[0]))!;
        _minute = Int(String(tokens[1]))!;
        dayOfWeek = String(tokens[2]);
    }
    
    var description: String {
        return "\(hour):\(minute):\(dayOfWeek)"
    }
    
    func getHour() -> Int {
        if let time = resolveTime() {
            return time.hour
        }
        return _hour
    }
    
    func getMinute() -> Int {
        if let time = resolveTime() {
            return time.minute
        }
        return _minute
    }
    
    func resolveTime() -> Time? {
        if dayOfWeek == "bw" {
            return settingsService.getWorkStartTime()
        }
        if dayOfWeek == "aw" {
            return settingsService.getWorkEndTime()
        }
        return nil
    }

}
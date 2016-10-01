//
//  NotificationTime.swift
//  Forms
//
//  Created by Justinas Marcinka on 01/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

class NotificationTime : CustomStringConvertible {
  var hour: Int
  var minute: Int
  var dayOfWeek: String
  var label: String
  let settingsService = SettingsService.instance
  
  //    Should use time of format HH:mm:dayOfWeek:label
  //    dayOfWeek: wd- working days, we - weekends
  //
  init (timestamp:String) {
    print("constructing from: \(timestamp)")
    var tokens = timestamp.characters.split{$0 == ":"};
    hour = Int(String(tokens[0]))!;
    minute = Int(String(tokens[1]))!;
    dayOfWeek = tokens.count > 2 ? String(tokens[2]): "ed";
    
    label = tokens.count > 3 ? String(tokens[3]) : "";
  }
  
  var description: String {
    return "\(hour):\(minute):\(dayOfWeek):\(label)"
  }
  
  
  func setTime(_ time: Time) {
    self.hour = time.hour
    self.minute = time.minute
  }
  
  func resolveTime() -> Time {
    return Time(hour: hour, minute: minute)
  }
  
}

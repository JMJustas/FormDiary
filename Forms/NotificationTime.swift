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
  static let calendar = Calendar(identifier: Calendar.Identifier.gregorian) as NSCalendar

  //    Should use time of format HH:mm:dayOfWeek:label
  //    dayOfWeek: wd- working days, we - weekends
  //
  init (timestamp:String) {
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
  
  func overlaps(other: NotificationTime, activeTime: Int) -> Bool {
    if self.dayOfWeek == "ed" || other.dayOfWeek == "ed" || other.dayOfWeek == self.dayOfWeek {
      let thisTime = NotificationTime.calendar.date(bySettingHour: self.hour, minute: self.minute, second: 0, of: Date(), options: [])! as Date
      let otherTime = NotificationTime.calendar.date(bySettingHour: other.hour, minute: other.minute, second: 0, of: Date(), options: [])! as Date
      let diff = abs(thisTime.timeIntervalSince1970 - otherTime.timeIntervalSince1970)
      return diff < Double(activeTime)
    }
    return false
  }
  
}

//
//  Form.swift
//  Forms
//
//  Created by Justinas Marcinka on 15/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation



class Form : CustomStringConvertible {
  let deviceId = IdService.instance._ID
  let ID_PATTERN = "**id**"
  
  var notificationTimes: [NotificationTime]
  var id: String
  var title: String
  var url: String
  var postponeCount: Int
  var postponeLimit: Int
  var postponeInterval: Int //time in seconds
  var description: String
  var accepted: Bool //boolean indicating if user has accepted to participate in survey
  var activeTime: Int
  var profileFormUrl: String
  var validUntil: Double //timestamp
  
  init(id: String, title: String, description: String, url: String, notificationTimes: [String], profileFormUrl: String, postponeLimit:Int = 0, postponeCount:Int = 0, postponeInterval:Int = 600, accepted:Bool = false, activeTime:Int = 1800, validUntil:Double) throws {
    self.id = id
    self.title = title
    self.description = description
    self.postponeInterval = postponeInterval
    self.url = url
    self.notificationTimes = []
    self.profileFormUrl = profileFormUrl.replacingOccurrences(of: ID_PATTERN, with: deviceId)
    self.postponeCount = postponeCount
    self.postponeLimit = postponeLimit
    self.accepted = accepted
    self.activeTime = activeTime
    self.validUntil = validUntil
    for notificationTimestamp in notificationTimes {
      self.notificationTimes.append(NotificationTime(timestamp: notificationTimestamp))
    }
  }
  
  
  //Deserialize JSON
  convenience init(json: [String: AnyObject]) throws{
    if let descr = json["description"] as? String,
      let id = json["id"] as? String,
      let title = json["title"] as? String,
      let url = json["url"] as? String,
      let profileFormUrl = json["profile_form_url"] as? String,
      let notificationTimes = json["notification_times"] as? [String],
      let activeTime = json["active_time"] as? Int,
      let postponeLimit = json["postpone_limit"] as? Int,
      let validUntil = json["valid_until"] as? Double {
      try self.init(id: id,
                    title: title,
                    description: descr.replacingOccurrences(of: "\\n", with: "\n"),
                    url: url,
                    notificationTimes: notificationTimes,
                    profileFormUrl: profileFormUrl,
                    postponeLimit: postponeLimit,
                    activeTime: activeTime,
                    validUntil: validUntil
      )
      if let postpone = json["postpone_interval"] as? Int {
        if postpone > 0 {
          self.postponeInterval = postpone
        }
      }
      
    } else {
      throw ParsingError.invalidInput
    }
  }
  
  convenience init(jsonString: String) throws {
    if let data = jsonString.data(using: String.Encoding.utf8) {
      let jsonObj = try JSONSerialization.jsonObject(with: data, options: [])  as? [String:AnyObject]
      if let json = jsonObj {
        try self.init(json: json)
        return
      } else {
        print("ERR1")
        throw FormCreationError.invalidJsonString
      }
    }
    print("ERR2")
    throw FormCreationError.invalidJsonString
  }
  
  func json(_ key:String, value: String) -> String {
    return "\"\(key)\": \"\(value)\""
  }
  func json(_ key:String, value: Int) -> String {
    return "\"\(key)\": \(value)"
  }
  func json(_ key:String, value: Double) -> String {
    return "\"\(key)\": \(value)"
  }
  
  //TODO move to external class
  func toJsonString() -> String {
    let id = json("id", value: self.id)
    let description = json("description", value: self.description.replacingOccurrences(of: "\n", with: "\\n"))
    let title = json("title", value: self.title)
    let url = json("url", value: self.url)
    let profileFormUrl = json("profile_form_url", value: self.profileFormUrl)
    let notificationTimes = self.serializeNotificationTimes()
    let postponeLimit = json("postpone_limit", value: self.postponeLimit)
    let activeTime = json("active_time", value: self.activeTime)
    let validUntil = json("valid_until", value: self.validUntil)
    let postponeInterval = json ("postpone_interval", value: self.postponeInterval)
    return "{\(id), \(description), \(title), \(url), \(profileFormUrl), \(notificationTimes), \(postponeLimit), \(activeTime), \(validUntil), \(postponeInterval)}"
  }
  func wrapInQuotes(_ text: String) -> String {
    return "\"\(text)\""
  }
  func serializeNotificationTimes() -> String {
    let times = notificationTimes.map ({element in return self.wrapInQuotes(element.description)})
    return "\(wrapInQuotes("notification_times")): [\(times.joined(separator: ","))]"
  }
}

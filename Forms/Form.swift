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
  
  init(id: String, title: String, description: String, url: String, notificationTimes: [String], profileFormUrl: String, postponeLimit:Int = 0, postponeCount:Int = 0, postponeInterval:Int = 600, accepted:Bool = false, activeTime:Int = 15) throws {
    self.id = id
    self.title = title
    self.description = description
    self.postponeInterval = postponeInterval
    self.url = url
    self.notificationTimes = []
    self.profileFormUrl = profileFormUrl.stringByReplacingOccurrencesOfString(ID_PATTERN, withString: deviceId)
    self.postponeCount = postponeCount
    self.postponeLimit = postponeLimit
    self.accepted = accepted
    self.activeTime = activeTime
    for notificationTimestamp in notificationTimes {
      self.notificationTimes.append(NotificationTime(timestamp: notificationTimestamp))
    }
  }
  
  
  
  //Constructs form from database result set
  convenience init(resultSet: FMResultSet) throws {
    let notificationTimes = resultSet.stringForColumn("notification_times")
    let times:Array<String> = notificationTimes.characters.split{$0 == ","}.map({el in return String(el)})
    try self.init(id: resultSet.stringForColumn("id"),
                  title: resultSet.stringForColumn("title"),
                  description: resultSet.stringForColumn("description"),
                  url: resultSet.stringForColumn("url"),
                  notificationTimes: times,
                  profileFormUrl: resultSet.stringForColumn("profile_form_url"),
                  postponeCount:Int(resultSet.intForColumn("postpone_count")),
                  postponeLimit:Int(resultSet.intForColumn("postpone_limit")),
                  postponeInterval:Int(resultSet.intForColumn("postpone_interval")),
                  accepted: resultSet.intForColumn("accepted") == 1,
                  activeTime: Int(resultSet.intForColumn("active_time"))
    )
  }
  
  
  //Deserialize JSON
  convenience init(json: [String: AnyObject]) throws{    
    if let descr = json["description"] as? String,
      id = json["id"] as? String,
      title = json["title"] as? String,
      url = json["url"] as? String,
      profileFormUrl = json["profile_form_url"] as? String,
      notificationTimes = json["notification_times"] as? [String],
      activeTime = json["active_time"] as? Int,
      postponeLimit = json["postpone_limit"] as? Int {
      
      try self.init(id: id,
                    title: title,
                    description: descr.stringByReplacingOccurrencesOfString("\\n", withString: "\n"),
                    url: url,
                    notificationTimes: notificationTimes,
                    profileFormUrl: profileFormUrl,
                    postponeLimit: postponeLimit,
                    activeTime: activeTime
      )
      if let postpone = json["postpone_interval"] as? Int {
        if postpone > 0 {
          self.postponeInterval = postpone
        }
      }
      
    } else {
      throw ParsingError.InvalidInput
    }
  }
  
  convenience init(jsonString: String) throws {
    if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
      let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: [])  as? [String:AnyObject]
      if let json = jsonObj {
        try self.init(json: json)
        return
      } else {
        print("ERR1")
        throw FormCreationError.InvalidJsonString
      }
    }
    print("ERR2")
    throw FormCreationError.InvalidJsonString
  }
  
  func json(key:String, value: String) -> String {
    return "\"\(key)\": \"\(value)\""
  }
  func json(key:String, value: Int) -> String {
    return "\"\(key)\": \(value)"
  }
  
  
  //TODO move to external class
  func toJsonString() -> String {
    let id = json("id", value: self.id)
    let description = json("description", value: self.description.stringByReplacingOccurrencesOfString("\n", withString: "\\n"))
    let title = json("title", value: self.title)
    let url = json("url", value: self.url)
    let profileFormUrl = json("profile_form_url", value: self.profileFormUrl)
    let notificationTimes = self.serializeNotificationTimes()
    let postponeLimit = json("postpone_limit", value: self.postponeLimit)
    let activeTime = json("active_time", value: self.activeTime)
    let postponeInterval = json ("postpone_interval", value: self.postponeInterval)
    return "{\(id), \(description), \(title), \(url), \(profileFormUrl), \(notificationTimes), \(postponeLimit), \(activeTime), \(postponeInterval)}"
  }
  func wrapInQuotes(text: String) -> String {
    return "\"\(text)\""
  }
  func serializeNotificationTimes() -> String {
    let times = notificationTimes.map ({element in return self.wrapInQuotes(element.description)})
    return "\(wrapInQuotes("notification_times")): [\(times.joinWithSeparator(","))]"
  }
}
//
//  Form.swift
//  Forms
//
//  Created by Justinas Marcinka on 15/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

enum ParsingError : ErrorType {
    case InvalidInput
}

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
    
    init(id: String, title: String, description: String, url: String, notificationTimes: [String], postponeLimit:Int = 0, postponeCount:Int = 0, postponeInterval:Int = 600, accepted:Bool = false, activeTime:Int = 15) throws {
        self.id = id
        self.title = title
        self.description = description
        self.postponeInterval = postponeInterval
        self.url = url.stringByReplacingOccurrencesOfString(ID_PATTERN, withString: deviceId)
        self.notificationTimes = []
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
                postponeCount:Int(resultSet.intForColumn("postpone_count")),
                postponeLimit:Int(resultSet.intForColumn("postpone_limit")),
                postponeInterval:Int(resultSet.intForColumn("postpone_interval")),
                accepted: resultSet.intForColumn("accepted") == 1,
                activeTime: Int(resultSet.intForColumn("active_time"))
            )
    }
    
    //Deserialize JSON
    convenience init(json: [String: AnyObject]) throws{
        NSLog("parsing JSON: \(json)")
        
        if let descr = json["description"] as? String,
            id = json["id"] as? String,
            title = json["title"] as? String,
            url = json["url"] as? String,
            notificationTimes = json["notification_times"] as? [String],
            activeTime = json["active_time"] as? Int,
            postponeLimit = json["postpone_limit"] as? Int {
                try self.init(id: id,
                    title: title,
                    description: descr.stringByReplacingOccurrencesOfString("\\n", withString: "\n"),
                    url: url,
                    notificationTimes: notificationTimes,
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
    
    func serializeNotificationTimes() -> String {
        let times = notificationTimes.map ({element in return element.description})
        return times.joinWithSeparator(",")
    }
}
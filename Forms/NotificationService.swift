//
//  NotificationService.swift
//  Forms
//
//  Created by Justinas Marcinka on 16/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation
import UIKit

class NotificationService {
    let alertTitle = "Reminder: fill out the form"
    
    static let instance = NotificationService()
    let logger = Logger.instance
    
    
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    var lastNotification: Date? = nil

  func scheduleNotification(_ formId: String, notificationId: String, when: Date, interval: NSCalendar.Unit? = nil, postponed: Bool = false) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = when
        localNotification.alertBody = alertTitle
        localNotification.soundName = UILocalNotificationDefaultSoundName // play default sound
        localNotification.userInfo = ["formId": formId, "postponed": postponed, "notificationId": notificationId]
        localNotification.category = "FORM_CATEGORY"
        if let repeatAt = interval {
            localNotification.repeatInterval = repeatAt
        }
        
        NSLog("scheduling next notification for form \(formId) at: \(when)")
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    

    
  func schedule(_ id: String, notificationId: String, time: NotificationTime, fromDate: Date) {
        var date = (calendar as NSCalendar).date(bySettingHour: time.hour, minute: time.minute, second: 0, of: fromDate, options: [])! as Date
        
        if !date.isAfter(fromDate) {
            date += 1.day
        }
        
        
        let daysToSkip = time.dayOfWeek == "wd" ?
            [1,7] :
            time.dayOfWeek == "we" ?
            [2,3,4,5,6] :
            []
        
        for _ in 0...6 {
            let dayOfWeek = (calendar as NSCalendar).component(.weekday, from: date)
            if daysToSkip.contains(dayOfWeek) {
                logger.log("Skipping schedule for \(date)")
            } else {
              scheduleNotification(id, notificationId: notificationId, when: date, interval: NSCalendar.Unit.weekOfYear)
            }

            date += 1.day
        }
        
    }
    
  func schedulePostponed(_ formId: String, notificationId: String, after: Int) {
        scheduleNotification(formId, notificationId: notificationId,
            when: Date(timeIntervalSinceNow: TimeInterval(after)),
            postponed: true
        )
    }
    
    func cancelNotifications(_ id: String) {
        logger.log("cancelling notifications for form \(id)")
        let app = UIApplication.shared
        self.getNotifications(id).forEach({notification in app.cancelLocalNotification(notification)})
    }
    
    func cancelAll() {
        logger.log("cancelling all notifications")
        let app = UIApplication.shared
        app.scheduledLocalNotifications?.forEach({notification in app.cancelLocalNotification(notification)})
    }


    func getNotifications(_ id: String) -> [UILocalNotification] {
        let app = UIApplication.shared
        if let notifications = app.scheduledLocalNotifications {
            return notifications.filter({
                notification in
                if let info = notification.userInfo as? [String:AnyObject], let formId = info["formId"] as? String {
                    return id == formId
                }
                return false
            })
        }
        return []
    }
//    loads date when the next notification will be fired for given form
    func nextNotificationDate(_ id: String) -> Date? {
        let notifications = self.getNotifications(id)
        var result: Date? = nil
        let now = Date()
        for notification in notifications {
            if let next = notification.nextFireDate() , next.isAfter(now) {
                if let res = result {
                    result = next.isBefore(res) ? next : result
                } else {
                    result = next as Date
                }
            }
        }
        return result
    }
    
//    loads last fired notification date for given form
    func lastNotificationDate(_ id: String) -> Date? {
        let defaults = UserDefaults.standard
        if self.lastNotification == nil {
            let secondsSinceEpoch = defaults.double(forKey: "lastNotificationTime")
            if secondsSinceEpoch > 0 {
                self.lastNotification = Date(timeIntervalSince1970: secondsSinceEpoch)
            } else {
                return nil
            }
        }
        return self.lastNotification

    }
    
    func markNotification(_ notification: UILocalNotification) {
        if let info = notification.userInfo as? [String:AnyObject], let formId = info["formId"] as? String, let postponed = info["postponed"] as? Bool {
            if (postponed) {
                NSLog("Postponed notification for form \(formId) won't extend survey active time. Ignoring...")
                return
            }
            self.lastNotification = Date()
            UserDefaults.standard.set(self.lastNotification!.timeIntervalSince1970, forKey: "lastNotificationTime")
          UserDefaults.standard.set(info, forKey: "lastNotificationInfo")
        } else {
            NSLog("Notification had missing data: \(notification.userInfo)")
        }
    }
  
  func getLastNotificationData() -> [String: AnyObject]?{
    return UserDefaults.standard.dictionary(forKey: "lastNotificationInfo") as [String : AnyObject]?
  }


}

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
    
    
    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    var lastNotification: NSDate? = nil

    func scheduleNotification(formId: String, when: NSDate, interval: NSCalendarUnit? = nil, postponed: Bool = false) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = when
        localNotification.alertBody = alertTitle
        localNotification.soundName = UILocalNotificationDefaultSoundName // play default sound
        localNotification.userInfo = ["formId": formId, "postponed": postponed]
        localNotification.category = "FORM_CATEGORY"
        if let repeatAt = interval {
            localNotification.repeatInterval = repeatAt
        }
        
        NSLog("scheduling next notification for form \(formId) at: \(when)")
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    

    
    func schedule(id: String, time: NotificationTime, fromDate: NSDate) {
        var date = calendar.dateBySettingHour(time.hour, minute: time.minute, second: 0, ofDate: fromDate, options: [])! as NSDate
        
        if !date.isAfter(fromDate) {
            date += 1.day
        }
        
        
        let daysToSkip = time.dayOfWeek == "wd" ?
            [1,7] :
            time.dayOfWeek == "we" ?
            [2,3,4,5,6] :
            []
        
        for _ in 0...6 {
            let dayOfWeek = calendar.component(.Weekday, fromDate: date)
            if daysToSkip.contains(dayOfWeek) {
                logger.log("Skipping schedule for \(date)")
            } else {
                scheduleNotification(id, when: date, interval: NSCalendarUnit.WeekOfYear)
            }

            date += 1.day
        }
        
    }
    
    func schedulePostponed(form: Form) {
        scheduleNotification(form.id,
            when: NSDate(timeIntervalSinceNow: NSTimeInterval(form.postponeInterval)),
            postponed: true
        )
    }
    
    func cancelNotifications(id: String) {
        logger.log("cancelling notifications for form \(id)")
        let app = UIApplication.sharedApplication()
        self.getNotifications(id).forEach({notification in app.cancelLocalNotification(notification)})
    }


    func getNotifications(id: String) -> [UILocalNotification] {
        let app = UIApplication.sharedApplication()
        if let notifications = app.scheduledLocalNotifications {
            return notifications.filter({
                notification in
                if let info = notification.userInfo as? [String:AnyObject], formId = info["formId"] as? String {
                    return id == formId
                }
                return false
            })
        }
        return []
    }
//    loads date when the next notification will be fired for given form
    func nextNotificationDate(id: String) -> NSDate? {
        let notifications = self.getNotifications(id)
        var result: NSDate? = nil
        let now = NSDate()
        for notification in notifications {
            if let next = notification.nextFireDate() where next.isAfter(now) {
                if let res = result {
                    result = next.isBefore(res) ? next : result
                } else {
                    result = next
                }
            }
        }
        return result
    }
    
//    loads last fired notification date for given form
    func lastNotificationDate(id: String) -> NSDate? {
        let defaults = NSUserDefaults.standardUserDefaults()
        if self.lastNotification == nil {
            let secondsSinceEpoch = defaults.doubleForKey("lastNotificationTime")
            if secondsSinceEpoch > 0 {
                self.lastNotification = NSDate(timeIntervalSince1970: secondsSinceEpoch)
            } else {
                return nil
            }
        }
        return self.lastNotification

    }
    
    func markNotification(notification: UILocalNotification) {
        if let info = notification.userInfo as? [String:AnyObject], formId = info["formId"] as? String, postponed = info["postponed"] as? Bool {
            if (postponed) {
                NSLog("Postponed notification for form \(formId) won't extend survey active time. Ignoring...")
                return
            }
            self.lastNotification = NSDate()
            NSUserDefaults.standardUserDefaults().setDouble(self.lastNotification!.timeIntervalSince1970, forKey: "lastNotificationTime")
        } else {
            NSLog("Notification had missing data: \(notification.userInfo)")
        }
        

    }


}
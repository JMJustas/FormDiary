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

    func scheduleNotification(formId: String, when: NSDate, interval: NSCalendarUnit? = nil) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = when
        localNotification.alertBody = alertTitle
        localNotification.soundName = UILocalNotificationDefaultSoundName // play default sound
        localNotification.userInfo = ["formId": formId ]
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
            when: NSDate(timeIntervalSinceNow: NSTimeInterval(form.postponeInterval))
        )
    }
    
    func cancelNotifications(id: String) {
        let app = UIApplication.sharedApplication()
        logger.log("cancelling notifications for form \(id)")
        if let notifications = app.scheduledLocalNotifications {
            notifications.filter({
                notification in
                    if let info = notification.userInfo as? [String:AnyObject], formId = info["formId"] as? String {
                        return id == formId
                    }
                    return false
            }).forEach({
                notification in
                    app.cancelLocalNotification(notification)
            })
        }
    }


}
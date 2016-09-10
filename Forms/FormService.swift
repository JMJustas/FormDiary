//
//  DataUpdater.swift
//  Forms
//
//  Created by Justinas Marcinka on 07/11/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation
import UIKit

class FormService {
  static let instance = FormService();
  let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
  let connector = FormDataConnector.instance
  let notificationService = NotificationService.instance
  let logger = Logger.instance
  var activeSurvey:Form? = nil;
  
  func joinSurvey(id: String, callback: (Form?) -> Void) {
    return connector.loadOne(id, handler: {
      formData in
      if let form = formData {
        form.accepted = true;
        let date = NSDate()
        self.notificationService.cancelNotifications(form.id)
        for (index,time) in form.notificationTimes.enumerate() {
          self.notificationService.schedule(form.id, notificationId: "\(index + 1))", time: time, fromDate: date)
        }
        self.setActive(form)
        return dispatch_async(dispatch_get_main_queue()) {
          callback(form)
        }
      }
      dispatch_async(dispatch_get_main_queue()) {
        callback(nil)
      }
    })
  }
  
  func leaveActiveSurvey() {
    if let form = loadActive() {
      self.notificationService.cancelNotifications(form.id)
      self.clearActive()
    } else {
      print("no active form")
    }
  }
  
  
  func getActiveSurveyId() -> String? {
    if let form = loadActive() {
      return form.id
    }
    return nil
  }
  
  func setActive(form: Form) {
    NSUserDefaults.standardUserDefaults().setValue(form.toJsonString(), forKey: "activeForm")
  }
  func clearActive() {
    NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "activeForm")
  }
  
  func loadActive() -> Form? {
    let data = NSUserDefaults.standardUserDefaults().stringForKey("activeForm")

    if let json = data {
      do {
        return try Form(jsonString: json)
      } catch {
        print("ERROR WHEN PARSING FORM DATA")
        return nil
      }
    }
    return nil
  }
}
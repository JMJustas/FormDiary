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
  let db = FormDataManager.instance
  let connector = FormDataConnector.instance
  let notificationService = NotificationService.instance
  let logger = Logger.instance
  var activeSurvey:Form? = nil;
  
  //
  //    Asynchronously loads and updates all forms data
  //
  func syncData(callback:(savedForms:[Form]) -> Void) {
    connector.loadFormsData({
      forms in
      
      dispatch_async(dispatch_get_global_queue(self.priority, 0)) {
        var outForms = [Form]()
        for form in forms {
          if let oldData = self.db.findForm(form.id) {
            form.accepted = oldData.accepted
            form.postponeCount = oldData.postponeCount
          }
          if let res = self.db.saveForm(form) {
            outForms.append(res)
          }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
          callback(savedForms: outForms)
        }
      }
    })
  }
  
  
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
        NSUserDefaults.standardUserDefaults().setValue(id, forKey: "ActiveSurvey")
        self.activeSurvey = form;
        return dispatch_async(dispatch_get_main_queue()) {
          callback(form)
        }
      }
      dispatch_async(dispatch_get_main_queue()) {
        callback(nil)
      }
    })
  }
  
  func leaveSurvey(id: String, callback: (Form?) -> Void) {
    if self.getActiveSurveyId() != id {
      logger.log("FORM with id \(id) is not active")
      return
    }
    self.notificationService.cancelNotifications(id)
    NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "ActiveSurvey")
    let form = self.activeSurvey
    self.activeSurvey = nil
    callback(form)
  }
  
  func load(id: String, callback: (Form?) -> Void) {
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
      let form = self.db.findForm(id)
      dispatch_async(dispatch_get_main_queue()) {
        callback(form)
      }
    }
  }
  
  func getActiveSurveyId() -> String? {
    let defaults = NSUserDefaults.standardUserDefaults()
    return defaults.stringForKey("ActiveSurvey")
  }
  
  func getActiveSurveyData() -> Form? {
    let defaults = NSUserDefaults.standardUserDefaults()
    if let payload = defaults.stringForKey("ActiveSurveyData") {
      do {
        let json = try NSJSONSerialization.JSONObjectWithData(payload.dataUsingEncoding(NSUTF8StringEncoding)!, options: [])
          as! [String: AnyObject]
        return try Form(json: json)
      } catch {
        return nil
      }
    }
    return nil
  }
  
  func loadActive(callback: (Form?) -> Void) {
    if let id = self.getActiveSurveyId() {
      if let form = self.activeSurvey {
        return self.executeInMainThread(callback, data: form)
      }
      return connector.loadOne(id, handler: {formLoadResult in
        if let form = formLoadResult {
          self.activeSurvey = form;
          return self.executeInMainThread(callback, data: form)
        }
      })
    }
    return executeInMainThread(callback, data: nil)
  }
  
  func executeInMainThread(callback: (Form?) -> Void, data: Form?) {
    dispatch_async(dispatch_get_main_queue()) {
      callback(data)
    }
    
  }
}
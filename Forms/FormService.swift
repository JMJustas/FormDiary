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
  let connector = FormDataConnector.instance
  let notificationService = NotificationService.instance
  let logger = Logger.instance
  var activeSurvey:Form? = nil;
  
  func joinSurvey(_ id: String, callback: @escaping (Form?) -> Void) {
    return connector.loadOne(id, handler: {
      formData in
      if let form = formData {
        self.joinSurvey(form)
        return DispatchQueue.main.async {
          callback(form)
        }
      }
      DispatchQueue.main.async {
        callback(nil)
      }
    })
  }
  
  func joinSurvey(_ form: Form) {
    form.accepted = true;
    let date = Date()
    self.notificationService.cancelNotifications(form.id)
    for (index,time) in form.notificationTimes.enumerated() {
      self.notificationService.schedule(form.id, notificationId: "\(index + 1))", time: time, fromDate: date)
    }
    self.setActive(form)
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
  
  func setActive(_ form: Form) {
    UserDefaults.standard.setValue(form.toJsonString(), forKey: "activeForm")
  }
  func clearActive() {
    UserDefaults.standard.setValue(nil, forKey: "activeForm")
  }
  
  func loadActive() -> Form? {
    let data = UserDefaults.standard.string(forKey: "activeForm")

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

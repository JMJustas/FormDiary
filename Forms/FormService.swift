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
    
    
    func joinSurvey(formArg: Form, callback: (Form?) -> Void) {
        dispatch_async(dispatch_get_global_queue(priority, 0)) {

            var res: Form?;
            if let form = self.db.findForm(formArg.id){
                form.accepted = true;
                let date = NSDate()
                self.notificationService.cancelNotifications(form.id)
                for time in form.notificationTimes {
                    self.notificationService.schedule(form.id, time: time, fromDate: date)
                }
                res = self.db.saveForm(form)

            }
            dispatch_async(dispatch_get_main_queue()) {
                callback(res)
            }
        }
    }
    
    func leaveSurvey(formArg: Form, callback: (Form?) -> Void) {
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            var res: Form?;
            if let form = self.db.findForm(formArg.id){
                form.accepted = false;
                self.notificationService.cancelNotifications(form.id)
                res = self.db.saveForm(form)
            } else {
                self.logger.log("form with id \(formArg.id) not found!")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                callback(res)
            }
        }
    }

    
    
}
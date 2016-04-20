//
//  NotificationActionHandler.swift
//  Forms
//
//  Created by Justinas Marcinka on 28/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation
import UIKit

class NotificationActionHandler: NSObject, UIAlertViewDelegate {
    var formId: String
    let formsMgr = FormDataManager.instance
    let notificationService = NotificationService.instance
    let DEFAULT_POSTPONE_LIMIT = 2
    let log = Logger.instance
    
    init(formId: String) {
        self.formId = formId
    }
    
    func loadForm() {
        if let form = formsMgr.findForm(formId) {
            form.postponeCount = 0
            formsMgr.saveForm(form)

            if let url = NSURL(string: form.url) {
                UIApplication.sharedApplication().openURL(url)
                log.log("opened survey for form \(formId)")
            } else {
                log.log("Failed to build url for form: \(formId)")
            }
        } else {
            log.log("Form with id \(formId) was not found")
        }
    }
    
    func postpone() {
        if let form = formsMgr.findForm(formId) {

            form.postponeCount += 1
            let limit = form.postponeLimit > 0 ? form.postponeLimit : DEFAULT_POSTPONE_LIMIT
            if form.postponeCount > limit {
                log.log("postpone count limit exceeded for form \(form.id)")
                self.skip()
                return
            }
            
            formsMgr.saveForm(form)
            notificationService.schedulePostponed(form)
            log.log("POSTPONED form \(form.id) Postpones left: \(limit - form.postponeCount)")
        } else {
            log.log("Form with id \(formId) was not found")
        }
    }
    
    func skip() {
        if let form = formsMgr.findForm(formId) {
            log.log("SKIPPED form \(formId)")
            
            form.postponeCount = 0
            formsMgr.saveForm(form)
        } else {
            log.log("Form with id \(formId) was not found")
        }
    }
}
//
//  FormViewController.swift
//  Forms
//
//  Created by Justinas Marcinka on 25/11/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation
import UIKit

class FormViewController: UIViewController {
 
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var fillButton: UIButton!
    @IBOutlet weak var remindButton: UIButton!
 
    
    let ENABLED_COLOR = UIColor(red:0.17, green:0.29, blue:0.58, alpha:1.0)
    let DISABLED_COLOR = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1.0)

    
    let log = Logger.instance
    let notificationService = NotificationService.instance
    let dateFormatter = NSDateFormatter()
    
    let formService = FormService.instance
    
    var nextNotification: NSDate?
    var lastNotification: NSDate?
    var timer: NSTimer?
    var form: Form?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dateFormatter.dateFormat = "HH:mm"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("FORM view did load")
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.formView = self;
        self.remindButton.hidden = true
        self.fillButton.hidden = true
        formService.loadActive({
            form in
            self.leaveButton.enabled = true
            self.titleLabel.text = form?.title
            self.form = form
            self.update(true)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        self.timer = startTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSLog("closing timer")
        self.timer?.invalidate()
        super.viewWillDisappear(animated)
    }
    
    //starts timer from the next minute
    private func startTimer() -> NSTimer {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Era, .Year, .Month, .Day, .Hour, .Minute], fromDate: date)
        components.minute += 1
        components.second = 0
        let nextMinuteDate = calendar.dateFromComponents(components)
        NSLog("will start timer at \(nextMinuteDate)")
        let timer = NSTimer(fireDate: nextMinuteDate!, interval: 60, target: self, selector: Selector("scheduledUpdate"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        return timer
    }
    
    func scheduledUpdate() {
        update(false)
    }
    
    func update(reloadNotifications:Bool) {
        if (reloadNotifications) {
            let formId = formService.getActiveSurveyId()
            if formId == nil {
                NSLog("NO ACTIVE FORM")
                return
            }
            self.nextNotification = notificationService.nextNotificationDate(formId!)
            self.lastNotification = notificationService.lastNotificationDate(formId!)
            if self.nextNotification != nil {
                self.notificationTimeLabel.text = "Next notification at: \(self.dateFormatter.stringFromDate(self.nextNotification!))"
            }
        }
        
        var showActions = false
        //TODO move to formService
        if let lastNotification = self.lastNotification, let form = self.form {
            let activeUntil = NSDate(timeInterval: Double(form.activeTime), sinceDate: lastNotification)
            let now = NSDate()
            if activeUntil.isAfter(now) {
                NSLog("Form \(form.id) is active until: \(activeUntil)")
                showActions = true
            } else {
                self.fillButton.enabled = true
            }
            
        }
        self.remindButton.enabled = true
        self.remindButton.backgroundColor = self.remindButton.enabled ? ENABLED_COLOR: DISABLED_COLOR
        self.fillButton.hidden = !showActions
        self.fillButton.backgroundColor = self.fillButton.enabled ? ENABLED_COLOR: DISABLED_COLOR
        self.remindButton.hidden = !showActions
    }
    
    
    @IBAction func onLeaveSurveyClick(sender: AnyObject) {
        leaveButton.enabled = false
        let handler: (Form?) -> Void = {form in
            self.leaveButton.enabled = true
            if form == nil {
                NSLog("ERROR: Failed to update form data when leaving survey!")
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        let formId = formService.getActiveSurveyId()!
        formService.leaveSurvey(formId, callback: handler)
    }

    @IBAction func onFillSurveyClick(sender: UIButton) {
        self.fillButton.enabled = false
        if let form = self.form {
            if let url = NSURL(string: form.url) {
                UIApplication.sharedApplication().openURL(url)
            } else {
                self.log.log("Failed to build url for form: \(form.id)")
            }
        } else {
            self.log.log("No active form")
        }
    }
    
    @IBAction func onPostponelick(sender: UIButton) {
         if let form = self.form {
            self.notificationService.schedulePostponed(form)
            self.update(true)
        }
        self.remindButton.enabled = false
        self.remindButton.backgroundColor = DISABLED_COLOR

    }
    
}

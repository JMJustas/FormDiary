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
    
    let log = Logger.instance
    let notificationService = NotificationService.instance
    let dateFormatter = NSDateFormatter()
    
    let formService = FormService.instance
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dateFormatter.dateFormat = "HH:mm"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formService.loadActive({
            form in
            self.leaveButton.enabled = true
            self.titleLabel.text = form?.title
            if form != nil {
                self.reloadNotificationTime(form!.id)
            }

        })
        
    }
    
    func reloadNotificationTime(id: String) {
        if let nextNotification = notificationService.nextNotificationDate(id) {
            self.notificationTimeLabel.text = "Next notification at: \(dateFormatter.stringFromDate(nextNotification))"
        }
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
        sender.enabled = false
        formService.loadActive({result in
            if let form = result {
                //            form.postponeCount = 0
                //            formsMgr.saveForm(form)
                
                if let url = NSURL(string: form.url) {
                    UIApplication.sharedApplication().openURL(url)
                } else {
                    self.log.log("Failed to build url for form: \(form.id)")
                }
            } else {
                self.log.log("No active form")
            }
            sender.enabled = true;
        })
    }
    
    @IBAction func onPostponelick(sender: UIButton) {
        sender.enabled = false
        formService.loadActive({result in
            if let form = result {
                self.notificationService.schedulePostponed(form)
                self.reloadNotificationTime(form.id)
            } else {
                self.log.log("No active form")
            }
            sender.enabled = true;
        })
    }
    
}

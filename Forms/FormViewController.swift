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
    let TEXT_JOIN = "Join survey"
    let TEXT_LEAVE = "Leave survey"
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet var button: UIButton!
    
    let formService = FormService.instance
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        formService.loadActive({
            form in
            self.title = form?.title
            self.descriptionView.text = form?.description;
            self.button.enabled = false
            self.initButton(true)
        })
        
    }
    //TODO reduce complexity
    func initButton(isParticipating: Bool) {
        let title = isParticipating ?  TEXT_LEAVE : TEXT_JOIN
        let textColor = isParticipating ? UIColor.redColor() : UIColor.blueColor()
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(textColor, forState: .Normal)
        button.enabled = true

        
    }
    
    @IBAction func onSubmit(sender: AnyObject) {
        button.enabled = false
        let handler: (Form?) -> Void = {form in
            self.button.enabled = true
            if form == nil {
                NSLog("ERROR: Failed to update form data when joining or leaving survey!")
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        let formId = formService.getActiveSurveyId()!
        formService.leaveSurvey(formId, callback: handler)
    }
}

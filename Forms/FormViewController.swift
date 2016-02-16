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
    let TEXT_LEAVE = ""
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet weak var button: UIButton!
    
    let formService = FormService.instance
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formService.loadActive({
            form in
            self.title = form?.title
            self.descriptionView.text = form?.description;
            self.button.enabled = true
        })
        
    }
    
    @IBAction func onLeaveSurveyClick(sender: AnyObject) {
        button.enabled = false
        let handler: (Form?) -> Void = {form in
            self.button.enabled = true
            if form == nil {
                NSLog("ERROR: Failed to update form data when leaving survey!")
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        let formId = formService.getActiveSurveyId()!
        formService.leaveSurvey(formId, callback: handler)
    }

}

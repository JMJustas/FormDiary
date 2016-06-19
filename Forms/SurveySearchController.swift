//
//  SurveySearchController.swift
//  Forms
//
//  Created by Justinas Marcinka on 12/02/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation
import UIKit

class SurveySearchController: UIViewController {

    let formService = FormService.instance
    let settingsService = SettingsService.instance
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    @IBOutlet weak var formSearchField: UITextField!
    
    override func viewDidLoad() {
        indicator.center = view.center
        view.addSubview(indicator)
    }
    
    override func viewWillAppear(animated: Bool) {
        formSearchField.text = nil
    }
    
    @IBAction func onSyncClick(sender: AnyObject) {
        formService.syncData({_ in})
    }
    @IBAction func onJoinClick(sender: UIButton) {
        //Do not allow to join a survey if no work end/start times present
        if settingsService.getWorkStartTime() == nil || settingsService.getWorkEndTime() == nil {
            return showSettings()
        }
        
        return joinForm(formSearchField.text)
    }
    
    func showSettings() {
        self.performSegueWithIdentifier("showSettings", sender: self)
    }
    
    func joinForm(idString:String?) {
        if let id = idString {
            self.indicator.startAnimating()
            
            formService.joinSurvey(id, callback: {
                result in
                self.indicator.stopAnimating()
                if let form = result {
                    let storyboard = UIStoryboard(name: "ActiveSurvey", bundle: nil)
                    let ctrl = storyboard.instantiateInitialViewController()
                    self.presentViewController(ctrl!, animated: false, completion: nil)
                    self.showProfileForm(form)
                } else {
                    //TODO show error toast
                }
            })
        }
    }
    
    func showProfileForm(form: Form) {
        if form.profileFormUrl.isEmpty {
            return
        }
        
        if let url = NSURL(string: form.profileFormUrl) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}


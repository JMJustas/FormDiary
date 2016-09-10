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
  var form: Form?
  
  @IBOutlet weak var formSearchField: UITextField!
  
  override func viewDidLoad() {
    indicator.center = view.center
    view.addSubview(indicator)
  }
  
  override func viewWillAppear(animated: Bool) {
    formSearchField.text = nil
  }
  
 
  @IBAction func onJoinClick(sender: UIButton) {
    if !Reachability.isConnectedToNetwork() {
      return AlertFactory.noInternetConnection().show()
    }
    return joinForm(formSearchField.text)
  }
  
  func joinForm(idString:String?) {
    if let id = idString {
      self.indicator.startAnimating()
      
      formService.joinSurvey(id, callback: {
        result in
        self.indicator.stopAnimating()
        if let form = result {
          self.form = form
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


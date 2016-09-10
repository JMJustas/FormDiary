//
//  SettingsController.swift
//  Forms
//
//  Created by Justinas Marcinka on 09/05/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UITableViewController {
  var form: Form?
  
  let settingsService = SettingsService.instance
  
  override func viewDidLoad() {
    if let formData = form {
      print(formData)
    } else {
      print("Form was not set")
    }
  }
  
  @IBAction func onBackButtonClick(sender: UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell =
      self.tableView.dequeueReusableCellWithIdentifier(
        "timePicker", forIndexPath: indexPath)
    
    
    
    return cell
  }
}
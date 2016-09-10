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
  
  let settingsService = SettingsService.instance
  var form: Form?
  
  override func viewDidLoad() {
    print(form)
  }
  
  @IBAction func onBackButtonClick(sender: UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let form = self.form {
      return form.notificationTimes.count
    }
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell =
      self.tableView.dequeueReusableCellWithIdentifier(
        "timePicker", forIndexPath: indexPath)
    
    
    
    return cell
  }
}
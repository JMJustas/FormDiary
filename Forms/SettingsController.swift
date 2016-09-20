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
  var notificationTimes: [NotificationTime] = []
  let formService = FormService.instance
  
  override func viewDidLoad() {
    if let form = self.form {
      self.notificationTimes = form.notificationTimes
    }
  }
  
  @IBAction func onBackButtonClick(sender: UIBarButtonItem) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  @IBAction func onSaveButtonClick(sender: UIBarButtonItem) {
    if let form = self.form {
      form.notificationTimes = notificationTimes.map({
        notificationTime in
        let res = NotificationTime(timestamp: notificationTime.description)
        

        return res
      })
      formService.joinSurvey(form)
    }
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) ->Int {
    return notificationTimes.count
  }
  
  func timePickerChanged(picker: UIDatePicker) {
    notificationTimes[picker.tag].setTime(Time(date: picker.date))
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell =
      self.tableView.dequeueReusableCellWithIdentifier(
        "timePicker", forIndexPath: indexPath) as! NotificationTimePickerView
    
    let notificationTime = notificationTimes[indexPath.row]
    
    cell.label.text = notificationTime.label
    cell.timePicker.date = notificationTime.resolveTime().toTodaysDate()
    cell.timePicker.tag = indexPath.row
    cell.timePicker.addTarget(self, action: #selector(SettingsController.timePickerChanged), forControlEvents: UIControlEvents.ValueChanged)
    return cell
  }
}
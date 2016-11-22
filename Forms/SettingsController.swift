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
  
  @IBOutlet weak var btnSave: UIBarButtonItem!
  @IBOutlet weak var btnCancel: UIBarButtonItem!
  
  let WEEKEND = NSLocalizedString("SETTINGS_LABEL_WEEKENDS", comment: "")
  let WORKDAY = NSLocalizedString("SETTINGS_LABEL_WORKING_DAYS", comment: "")
  let EVERYDAY = NSLocalizedString("SETTINGS_LABEL_EVERY_DAY", comment: "")
  
  override func viewDidLoad() {
    self.title = NSLocalizedString("SETTINGS_VIEW_TITLE", comment: "")
    self.btnCancel.title = NSLocalizedString("SETTINGS_BUTTON_CANCEL", comment: "")

    self.btnSave.title = NSLocalizedString("SETTINGS_BUTTON_SAVE", comment: "")
    if let form = self.form {
      self.notificationTimes = form.notificationTimes
    }
  }
  
  @IBAction func onBackButtonClick(_ sender: UIBarButtonItem) {
    if let ctrl = self.navigationController {
      ctrl.popViewController(animated: true)
    }
  }
  @IBAction func onSaveButtonClick(_ sender: UIBarButtonItem) {
    if let form = self.form {
      form.notificationTimes = notificationTimes.map({
        notificationTime in
        return NotificationTime(timestamp: notificationTime.description)
      })
      
      for t1 in form.notificationTimes {
        for t2 in form.notificationTimes {
          if t1 === t2 {
            continue
          }
          if t1.overlaps(other: t2, activeTime: form.activeTime) {
            return AlertFactory.overlappingNotifications().show()
          }
        }
      }
      
      formService.joinSurvey(form)
    }
    if let ctrl = self.navigationController {
      ctrl.popViewController(animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->Int {
    return notificationTimes.count
  }
  
  func timePickerChanged(_ picker: UIDatePicker) {
    notificationTimes[picker.tag].setTime(Time(date: picker.date))
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell =
      self.tableView.dequeueReusableCell(
        withIdentifier: "timePicker", for: indexPath) as! NotificationTimePickerView
    
    let notificationTime = notificationTimes[(indexPath as NSIndexPath).row]
    
    cell.label.text = self.buildDisplayLabel(notificationTime: notificationTime)
    cell.timePicker.date = notificationTime.resolveTime().toTodaysDate() as Date
    cell.timePicker.tag = (indexPath as NSIndexPath).row
    cell.timePicker.addTarget(self, action: #selector(SettingsController.timePickerChanged), for: UIControlEvents.valueChanged)
    return cell
  }
  
  func buildDisplayLabel(notificationTime: NotificationTime) -> String {
    var label = "";
    if notificationTime.dayOfWeek == "we" {
      label.append(WEEKEND)
    } else if notificationTime.dayOfWeek == "wd" {
      label.append(WORKDAY)
    } else {
      label.append(EVERYDAY)
    }
    
    label.append(", \(notificationTime.label)")
    
    return label
  }
}

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
  @IBOutlet weak var leaveButton: UIButton!
  @IBOutlet weak var fillButton: UIButton!
  @IBOutlet weak var remindButton: UIButton!
  @IBOutlet weak var descriptionText: UITextView!
  @IBOutlet weak var settingsNavButton: UIBarButtonItem!
  
  let DEFAULT_POSTPONE_INTERVAL = 600;
  let deviceId = IdService.instance._ID
  let ENABLED_COLOR = UIColor(red:0.17, green:0.29, blue:0.58, alpha:1.0)
  let DISABLED_COLOR = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1.0)
  
  
  let log = Logger.instance
  let notificationService = NotificationService.instance
  let dateFormatter = DateFormatter()
  
  let formService = FormService.instance
  
  var nextNotification: Date?
  var lastNotification: Date?
  var timer: Timer?
  var form: Form?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    dateFormatter.dateFormat = "HH:mm"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    delegate.formView = self;
    
    self.fillButton.setTitle(NSLocalizedString("FORM_BUTTON_FILL_SURVEY", comment: ""), for: .normal)
    self.remindButton.setTitle(NSLocalizedString("FORM_BUTTON_REMIND", comment: ""), for: .normal)
    self.leaveButton.setTitle(NSLocalizedString("FORM_BUTTON_LEAVE", comment: ""), for: .normal)
    self.settingsNavButton.title = NSLocalizedString("FORM_BUTTON_SETTINGS", comment: "")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.form = formService.loadActive()
    if checkIfFormExpired() {
      print("expired")
      formService.leaveActiveSurvey()
      dismiss(animated: false, completion: nil)
      return
    }
    self.leaveButton.isEnabled = true
    self.title = self.form?.title
    descriptionText.text = self.form?.description.replacingOccurrences(of: "\\n", with: "\n")
    self.update(true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.timer = startTimer()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.timer?.invalidate()
    super.viewWillDisappear(animated)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showSettings" {
      let ctrl = segue.destination as! SettingsController
      ctrl.form = self.form
    }
  }
  
  func checkIfFormExpired() -> Bool {
    if let expireTimestamp = self.form?.validUntil {
      let expirationDate = Date(timeIntervalSince1970: expireTimestamp)
      let now = Date()
      return expirationDate.isBefore(now)
    }
    return true
  }
  
  //starts timer from the next minute
  fileprivate func startTimer() -> Timer {
    let date = Date()
    let calendar = Calendar.current
    var components = (calendar as NSCalendar).components([.era, .year, .month, .day, .hour, .minute], from: date)
    components.minute? += 1
    components.second = 0
    let nextMinuteDate = calendar.date(from: components)
    NSLog("will start timer at \(nextMinuteDate)")
    let timer = Timer(fireAt: nextMinuteDate!, interval: 60, target: self, selector: #selector(FormViewController.scheduledUpdate), userInfo: nil, repeats: true)
    RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    return timer
  }
  
  func scheduledUpdate() {
    update(false)
  }
  
  func update(_ reloadNotifications:Bool) {
    if (reloadNotifications) {
      let formId = formService.getActiveSurveyId()
      if formId == nil {
        return
      }
      self.nextNotification = notificationService.nextNotificationDate(formId!)
      self.lastNotification = notificationService.lastNotificationDate(formId!)
      if self.nextNotification != nil {
        self.notificationTimeLabel.text = "\(NSLocalizedString("FORM_LABEL_NEXT_NOTIFICATION_TIME", comment: "")) \(self.dateFormatter.string(from: self.nextNotification!))"
      }
    }
    
    var showActions = false
    
    if let lastNotification = self.lastNotification, let form = self.form {
      let activeUntil = Date(timeInterval: Double(form.activeTime), since: lastNotification)
      let now = Date()
      if activeUntil.isAfter(now) {
        NSLog("Form \(form.id) is active until: \(activeUntil)")
        showActions = true
      }
    }
    self.remindButton.isEnabled = showActions
    self.remindButton.backgroundColor = self.remindButton.isEnabled ? ENABLED_COLOR: DISABLED_COLOR
    self.fillButton.isEnabled = showActions
    self.fillButton.backgroundColor = self.fillButton.isEnabled ? ENABLED_COLOR: DISABLED_COLOR
  }
  
  
  @IBAction func onLeaveSurveyClick(_ sender: AnyObject) {
    leaveButton.isEnabled = false
    formService.leaveActiveSurvey()
    self.leaveButton.isEnabled = true
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onFillSurveyClick(_ sender: UIButton) {
    self.fillButton.isEnabled = false
    if let form = self.form, let lastNotificationData = notificationService.getLastNotificationData() {
      
      
      var urlString = form.url
        .replacingOccurrences(of: "**id**", with: deviceId)
      if let notificationId = (lastNotificationData["notificationId"] as! String).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
      {
        urlString = urlString.replacingOccurrences(of: "**notificationId**", with: notificationId)
      }
      if let url = URL(string: urlString) {
        UIApplication.shared.openURL(url)
        notificationService.clearLastNotificationDate()
        self.fillButton.isEnabled = true
      } else {
        self.log.log("Failed to build url for form: \(form.id)")
      }
    } else {
      self.log.log("No active form")
    }
  }
  
  @IBAction func onPostponelick(_ sender: UIButton) {
    if let lastNotificationData = notificationService.getLastNotificationData() {
      self.notificationService.schedulePostponed(lastNotificationData["formId"] as! String, notificationId: lastNotificationData["notificationId"] as! String, after: DEFAULT_POSTPONE_INTERVAL)
      self.update(true)
    }
    self.remindButton.isEnabled = false
    self.remindButton.backgroundColor = DISABLED_COLOR
    
  }
  
}

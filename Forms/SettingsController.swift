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
    
    @IBOutlet weak var workStartTimePicker: UIDatePicker!
    @IBOutlet weak var workEndTimePicker: UIDatePicker!
    
    let settingsService = SettingsService.instance
    
    override func viewDidLoad() {
        if let workStartTime = settingsService.getWorkStartTime() {
            workStartTimePicker.date = workStartTime.toTodaysDate()
        }
        
        if let workEndTime = settingsService.getWorkEndTime() {
           workEndTimePicker.date = workEndTime.toTodaysDate()
        }
    }
    
    @IBAction func onBackButtonClick(sender: UIBarButtonItem) {
        saveSettings()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveSettings() {
        settingsService.setWorkStartTime(Time(date: workStartTimePicker.date))
        settingsService.setWorkEndTime(Time(date: workEndTimePicker.date))
    }
}
//
//  SettingsService.swift
//  Forms
//
//  Created by Justinas Marcinka on 09/05/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation

class SettingsService {
    static let instance = SettingsService()
    
    func setWorkStartTime(_ time: Time) {
        UserDefaults.standard.setValue(time.description, forKey: "workStartTime")
    }
    
    func setWorkEndTime(_ time: Time) {
        UserDefaults.standard.setValue(time.description, forKey: "workEndTime")
    }
    
    func getWorkStartTime() -> Time? {
        if let timestamp = UserDefaults.standard.string(forKey: "workStartTime") {
            return Time(timestamp: timestamp)
        }
        return nil
    }
    
    func getWorkEndTime() -> Time? {
        if let timestamp = UserDefaults.standard.string(forKey: "workEndTime") {
            return Time(timestamp: timestamp)
        }
        return nil
    }
}

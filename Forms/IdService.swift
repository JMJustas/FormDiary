//
//  IdService.swift
//  Forms
//
//  Created by Justinas Marcinka on 25/11/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation
import UIKit

class IdService {
    let ID_KEY = "forms_device_id"
    static let instance = IdService()
    var _ID: String;
    
    init() {
        let defaults = UserDefaults.standard
        if let id = defaults.string(forKey: ID_KEY) {
            _ID = id
            NSLog("ID exists: \(_ID)")
        } else {
            _ID = UIDevice.current.identifierForVendor!.uuidString
            NSLog("created new device id: \(_ID)")
            defaults.set(_ID, forKey: ID_KEY)
        }
    }
}

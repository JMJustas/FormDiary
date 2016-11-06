//
//  AlertFactory.swift
//  Forms
//
//  Created by Justinas Marcinka on 23/07/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation
import UIKit

class AlertFactory {
  class func noInternetConnection() -> UIAlertView {
    return UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
  }
  class func failedToLoadData() -> UIAlertView {
    return UIAlertView(title: "Failed to load form data", message: "Make sure form exists in google spreadsheet.", delegate: nil, cancelButtonTitle: "OK")
  }
  class func overlappingNotifications() -> UIAlertView {
    return UIAlertView(title: "Invalid data", message: "Overlapping.", delegate: nil, cancelButtonTitle: "OK")
  }
}

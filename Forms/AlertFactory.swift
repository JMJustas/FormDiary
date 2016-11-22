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
    return UIAlertView(title: NSLocalizedString("ALERT_NO_INTERNET_TITLE", comment: ""), message: NSLocalizedString("ALERT_NO_INTERNET_MESSAGE", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ALERT_OK_BUTTON", comment: ""))
  }
  class func failedToLoadData() -> UIAlertView {
    return UIAlertView(title: NSLocalizedString("ALERT_FAILED_FORM_LOAD_TITLE", comment: ""), message: NSLocalizedString("ALERT_FAILED_FORM_LOAD_MESSAGE", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ALERT_OK_BUTTON", comment: ""))
  }
  class func overlappingNotifications() -> UIAlertView {
    return UIAlertView(title: NSLocalizedString("ALERT_OVERLAPPING_NOTIFICATIONS_TITLE", comment: ""), message: NSLocalizedString("ALERT_OVERLAPPING_NOTIFICATIONS_MESSAGE", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("ALERT_OK_BUTTON", comment: ""))
  }
}

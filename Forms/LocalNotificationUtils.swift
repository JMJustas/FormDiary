//
//  LocalNotificationUtils.swift
//  Forms
//
//  Created by Justinas Marcinka on 20/02/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation
import UIKit
extension UILocalNotification {
    func nextFireDate () -> NSDate? {
        let now = NSDate()
        if let fireDate = self.fireDate {
            var result = NSDate(timeIntervalSince1970: fireDate.timeIntervalSince1970)
            while (true) {
                if (!result.isBefore(now)) {
                    return result
                }
                result += (1, self.repeatInterval)
            }
        } else {
            return nil
        }
        
        
    }
}
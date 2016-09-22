//
//  NotificationTimePickerView.swift
//  Forms
//
//  Created by Justinas Marcinka on 19/09/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation
import UIKit

class NotificationTimePickerView: UITableViewCell {
  
  var timeChangeHandler: ((Time) -> Void)?
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var timePicker: UIDatePicker!
}

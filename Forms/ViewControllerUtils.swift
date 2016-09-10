//
//  ViewControllerUtils.swift
//  Forms
//
//  Created by Justinas Marcinka on 25/08/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
  func execInUIThread(handler: (AnyObject?) -> Void) -> (AnyObject?) -> Void {
    return { result in
      dispatch_async(dispatch_get_main_queue()) {
        handler(result)
      }
    }
  }
}
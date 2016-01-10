//
//  Logger.swift
//  Forms
//
//  Created by Justinas Marcinka on 28/12/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

class Logger {
    static let instance = Logger();
    
    func log(msg: String) {
        NSLog(msg)
    }
}
//
//  Errors.swift
//  Forms
//
//  Created by Justinas Marcinka on 10/09/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation

enum FormCreationError: Error {
  case invalidJsonString
}

enum FormAction: Error {
  case noActiveForm
}

enum ParsingError : Error {
  case invalidInput
}

//
//  Errors.swift
//  Forms
//
//  Created by Justinas Marcinka on 10/09/16.
//  Copyright © 2016 jm. All rights reserved.
//

import Foundation

enum FormCreationError: ErrorType {
  case InvalidJsonString
}

enum FormAction: ErrorType {
  case NoActiveForm
}

enum ParsingError : ErrorType {
  case InvalidInput
}
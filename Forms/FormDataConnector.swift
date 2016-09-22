//
//  FormDataConnector.swift
//  Forms
//
//  Created by Justinas Marcinka on 12/11/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

class FormDataConnector {
  static let instance = FormDataConnector()
  static let TEST_URL = "https://script.google.com/macros/s/AKfycbxH1Kzc7inDnIBiGCyhohv5Neji9riFmLRsPXidQTZGhesaQ1E/exec";
  
  let API_URL = TEST_URL;
  
  static let config = URLSessionConfiguration.default
  let session = URLSession(configuration: config)
  
  func loadOne(_ formId: String, handler: @escaping (Form?) -> Void) {
    session.dataTask(with: URL(string: "\(API_URL)?formId=\(formId)")!, completionHandler: {(data, response, error) in
      
      if let payload = data {
        do {
          let json = try JSONSerialization.jsonObject(with: payload, options: []) as! [String: AnyObject]
          if let status = json["status"] as? String{
            if status == "OK" {
              handler(self.parseForm(json["data"]))
              return;
            }
            
          }
          
        } catch {
          handler(nil)
          return
        }
      }
      handler(nil)
      return
      
      
    }).resume()
  }
  
  func parseForm(_ entry: AnyObject?) -> Form? {
    do {
      if let json = entry as? [String:AnyObject]{
        return try Form (json: json)
      }
    } catch {
      return nil
    }
    return nil
  }
  
  func loadFormsData(_ handler: @escaping ([Form]) -> Void) {
    NSLog("Loading data...")
    session.dataTask(with: URL(string: API_URL)!, completionHandler: {(data, response, error) in
      if let err = error {
        NSLog("ERROR while fetching forms data: \(err)")
      } else if let payload = data {
        do {
          let json = try JSONSerialization.jsonObject(with: payload, options: []) as! [String: AnyObject]
          if let status = json["status"] as? String {
            if let entries = json ["data"] as? [[String: AnyObject]] {
              if status == "OK" {
                handler(self.parseEntries(entries))
                return
              }
            }
          }
          NSLog("Invalid JSON: \(json)")
        } catch let error as NSError {
          NSLog("Failed to parse JSON: \(error.localizedDescription)")
        }
      } else {
        NSLog("ERROR parsing fetched forms data")
      }
      handler([])
      
    }).resume();
    
  }
  
  func parseEntries(_ entries: [[String: AnyObject]]) -> [Form] {
    var result: [Form] = []
    for entry in entries {
      do {
        let form = try Form (json: entry)
        result.append(form)
      } catch let error as NSError {
        NSLog("Failed to parse JSON: \(error.localizedDescription)")
      }
    }
    return result
  }
}

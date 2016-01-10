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
    static let TEST_URL = "https://script.googleusercontent.com/macros/echo?user_content_key=nIgQMgbhoEw2WiX7a4t8SbwNKRsZbmtjCrsyRzlH36YGJw4vOE9ik_xVsawhypt9ylVAji3_lg-BQfQ4L9lkp80uAz_3033mm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnHAdZxMGFWO0vYyNAwealdAQtpUfH8HGJsWbmN1e_T8vdcay2QGMxUfL96ChSmoQrKOIp7sEUsJ2&lib=MynG0CqcJILwXYfWRoICq9gGgahm_W7Lh";
    
    let API_URL = TEST_URL;
    
    static let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)
    
    func loadFormsData(handler: ([Form]) -> Void) {
        NSLog("Loading data...")
        session.dataTaskWithURL(NSURL(string: API_URL)!, completionHandler: {(data, response, error) in
            if let err = error {
                NSLog("ERROR while fetching forms data: \(err)")
            } else if let payload = data {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(payload, options: []) as! [String: AnyObject]
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
    
    func parseEntries(entries: [[String: AnyObject]]) -> [Form] {
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
//
//  FormDataManager.swift
//  Forms
//
//  Created by Justinas Marcinka on 20/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

class FormDataManager {
    static let instance = FormDataManager()
    let dbManager = DataManager.instance
    
    
    
    func findForm(id: String) -> Form? {
        var ret: Form? = nil
        dbManager.executeInQueue { db in
            if let resultSet = db.executeQuery("SELECT * FROM forms where id=?", withArgumentsInArray: [id]) {
                if (resultSet.next()) {
                    let formId = resultSet.stringForColumn("id")
                    do {
                        ret = try Form(resultSet: resultSet)
                    } catch {
                        NSLog("Error building form model. form id: \(formId)")
                    }
                }
                resultSet.close()
            }

        }
        return ret
    }
    
    func loadAll() -> [Form] {
        var result: [Form] = []
        dbManager.executeInQueue { db in
            if let resultSet = db.executeQuery("SELECT * FROM forms", withArgumentsInArray: nil) {
                while (resultSet.next()) {
                    let formId = resultSet.stringForColumn("id")
                    do {
                        let form = try Form(resultSet: resultSet)
                        result.append(form);
                    } catch {
                        print("Error building form model. form id: \(formId)")
                    }
                }
                resultSet.close()
            }
        }
        return result
    }

    
    
    func saveForm(form: Form) -> Form? {
        let args = [
            form.title,
            form.description,
            form.url,
            form.serializeNotificationTimes(),
            form.postponeCount,
            form.postponeLimit,
            form.postponeInterval,
            form.accepted ? 1 : 0,
            form.activeTime,
            form.id
        ]

        let stmt = findForm(form.id) == nil ?
            "INSERT INTO forms (title, description, url, notification_times, postpone_count, postpone_limit, postpone_interval, accepted, active_time, id) VALUES (?,?,?,?,?,?,?,?,?,?)":
            "UPDATE forms SET title=?, description=?, url=?, notification_times=?, postpone_count=?, postpone_limit=?, postpone_interval=?, accepted=?, active_time=? where id=?";
        var res: Form?
        dbManager.executeInQueue { db in
           res = db.executeUpdate(stmt, withArgumentsInArray: args as [AnyObject]) ? form : nil
        }
        return res
    }
    
    
    func deleteForm(id: String) -> Bool {
        return false
    }
    
    func loadAll(callback: ([Form]) -> Void) {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let result = self.loadAll()
            dispatch_async(dispatch_get_main_queue()) {
                callback(result)
            }
        }
    }

}

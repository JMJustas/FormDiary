//
//  FormsViewController.swift
//  Forms
//
//  Created by Justinas Marcinka on 22/11/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation
import UIKit

class FormsListController: UITableViewController {
    let dataManager = FormDataManager.instance
    let formService = FormService.instance
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var forms = [Form]()
    var acceptedForms = [Form]()
    var unacceptedForms = [Form]()
    let sectionTitles: [String] = ["Your surveys: ", "Active surveys: "]
    var data: [Int: [Form]] = [Int: [Form]]()
    var selectedForm: Form!
    let SYNC_INTERVAL: Double = 86400
    
    @IBOutlet var table: UITableView!

    
    
    override func viewDidLoad() {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.formsList = self
        indicator.center = view.center
        view.addSubview(indicator)

        
    }
 
    @IBAction func onClick(sender: AnyObject) {
        NSLog("CLICKED")
        self.reload(true)
    }
    
    func reload(forceSync: Bool = false) {
        NSLog("reloading forms. ForceSync: \(forceSync)")
        let reloadHandler = {
            (data: [Form]) -> Void in
            self.data[0] = data.filter({$0.accepted})
            self.data[1] = data.filter({!$0.accepted})
            self.tableView.reloadData()
            self.indicator.stopAnimating()
            
        }
        
        
        self.indicator.startAnimating()
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastUpdate = defaults.doubleForKey("lastSyncDate")
        
        let now = NSDate().timeIntervalSince1970
        let shouldSync = false // (now - lastUpdate) > SYNC_INTERVAL
        
        
        if forceSync || shouldSync {
            NSLog("Updating form data from backend")
            formService.syncData({ _ in
                defaults.setDouble(now, forKey: "lastSyncDate")
                self.dataManager.loadAll(reloadHandler)
            })
        } else {
            dataManager.loadAll(reloadHandler)
        }
        

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsInSection(section)
    }
    
    func rowsInSection(section:Int) -> Int {
        if let items = self.data[section] {
            return items.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let form = self.data[indexPath.section]![indexPath.row]
        cell.textLabel!.text = form.title
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section] + String(rowsInSection(section))
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FormView" {
            let target = segue.destinationViewController as! FormViewController
            let index = table.indexPathForSelectedRow!
            target.form = data[index.section]![index.row]
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Logger.instance.log("Will appear")

        reload()
    }
    
}

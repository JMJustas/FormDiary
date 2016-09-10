//
//  AppDelegate.swift
//  Forms
//
//  Created by Justinas Marcinka on 24/09/15.
//  Copyright © 2015 jm. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var formView: FormViewController?
  
  let formDataManager = FormDataManager.instance
  let dataManager = DataManager.instance
  let notificationService = NotificationService.instance
  let formService = FormService.instance
  let dataConnector = FormDataConnector.instance
  
  
  let alertTitle = "Reminder: fill out the form"
  let actionFill = "Fill survey"
  let actionPostpone = "Postpone"
  let actionSkip = "Skip"
  
  let createDb = false
  let createTestData = false
  let testScheduling = false
  let logger = Logger.instance
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    let category = UIMutableUserNotificationCategory() // notification categories allow us to create groups of actions that we can associate with a notification
    category.identifier = "FORM_CATEGORY"
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories:[category]))
    
    NSLog("DELEGATE INITIALIZED")
    return true
  }
  
  func insertTestData() {
    let times = ["19:00:we", "20:00:we"]
    let testForm = try! Form(id: "test", title: "test", description: "test form", url: "https://docs.google.com/forms/d/1ON0IpHQXjQ_TPHRP7ioEZXWbZC9YjDBCRQm09VinmLk/viewform?entry.1280822523=**id**", notificationTimes: times, profileFormUrl: "https://docs.google.com/forms/d/19BgZmI8oXbjopYmDa9l5WMDXwT1_Mj4Ofwfx8MZ_FZo/viewform?entry.135011125=**id**", postponeLimit: 1, postponeInterval: 10)
    formDataManager.saveForm(testForm)
  }
  
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)  {
    logger.log("got notification \(notification). Form view: \(formView)")
    notificationService.markNotification(notification)
    formView?.update(true)
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    self.formView?.update(true)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
  
}


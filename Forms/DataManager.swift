//
//  Datamanager.swift
//  Forms
//
//  Created by Justinas Marcinka on 19/10/15.
//  Copyright © 2015 jm. All rights reserved.
//

import Foundation

class DataManager {
    static let instance = DataManager()
    let DB_VERSION = 1;

    var db: FMDatabase
    var queue: FMDatabaseQueue
    
    init() {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)
        let docsDir = dirPaths[0] as String;
        
        let databasePath = docsDir + "/forms.db";
        NSLog("Db path: \(databasePath)")
        db = FMDatabase(path: databasePath as String);
        queue = FMDatabaseQueue(path: databasePath as String)
    }
    
    func initDb(recreateDb: Bool = false) {
        NSLog("Initializing DB on thread \(NSThread.currentThread())")
        if db.open() {
            let dbVer = Int(db.userVersion())
            if (recreateDb || dbVer != DB_VERSION) {
                upgradeDb(db, verFrom: dbVer, verTo: DB_VERSION);
                db.setUserVersion(UInt32(DB_VERSION))
            }
            db.close();
        } else {
            NSLog("FAILED TO OPEN DB: " + db.lastErrorMessage());
        }
        
        NSLog("FINISHED Initializing DB on thread \(NSThread.currentThread())")

        return;
    }
    
    func getDb() -> FMDatabase? {
        if !db.open() {
            return nil
        }
        return db;
    }
    
    func executeInQueue(what: (FMDatabase!) -> Void){
        self.queue.inDatabase(what)
    }
    
    func upgradeDb(db: FMDatabase, verFrom: Int, verTo: Int) {
        dropTables(db);
        createTables(db);
    }
    
    func dropTables(db: FMDatabase) {
        NSLog("DROPPING TABLES");
        db.executeStatements("DROP TABLE IF EXISTS meta");
        db.executeStatements("DROP TABLE IF EXISTS forms");
    }
    
    
    func createTables(db: FMDatabase) -> Bool {
        NSLog("CREATING TABLES")
        //META TABLE
        if !db.executeStatements("CREATE TABLE IF NOT EXISTS forms (id TEXT PRIMARY KEY, title TEXT, description TEXT, url TEXT, notification_times TEXT, postpone_count INT, postpone_limit INT, postpone_interval INT, accepted INT)"){
            NSLog("Error: " + db.lastErrorMessage());
            return false;
        }
        
        return true
    }
    
}
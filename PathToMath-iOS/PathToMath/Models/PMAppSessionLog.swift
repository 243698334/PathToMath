//
//  PMAppSessionLog.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/20/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

let kPMAppSessionLogClassName = "AppSessionLog"
let kPMAppSessionLogUserKey = "user"
let kPMAppSessionLogLaunchTimestampKey = "launchTimestamp"

let kPMLocalDatastoreAppSessionLogPinName = "AppSessionLog"

class PMAppSessionLog: PFObject, PFSubclassing {

    @NSManaged var user: PMUser!
    @NSManaged var launchTimestamp: NSDate!
    @NSManaged var terminateTimestamp: NSDate!
    
    class func parseClassName() -> String {
        return kPMAppSessionLogClassName
    }
    
}

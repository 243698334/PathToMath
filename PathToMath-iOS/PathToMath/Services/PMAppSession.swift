//
//  PMAppSession.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/21/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

class PMAppSession: PFSession {
    
    static var appSessionLog: PMAppSessionLog?
    
    class func applicationDidBecomeActive() {
        if (PMUser.currentUser() == nil || PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) == true) {
            self.appSessionLog = nil
            return
        }
        
        self.appSessionLog = PMAppSessionLog()
        self.appSessionLog?.ACL = PFACL(user: PMUser.currentUser()!)
        self.appSessionLog?.user = PMUser.currentUser()
        self.appSessionLog?.launchTimestamp = NSDate()
        self.appSessionLog?.pinInBackgroundWithName(kPMLocalDatastoreAppSessionLogPinName)
    }
    
    class func applicationWillResignActive() {
        if (self.appSessionLog == nil) {
            return
        }
        
        self.appSessionLog?.terminateTimestamp = NSDate()
        self.appSessionLog?.saveEventually()
    }
    
    class func userDidLogin() {
        if (self.appSessionLog != nil) {
            return
        }
        
        self.appSessionLog = PMAppSessionLog()
        self.appSessionLog?.ACL = PFACL(user: PMUser.currentUser()!)
        self.appSessionLog?.user = PMUser.currentUser()
        self.appSessionLog?.launchTimestamp = NSDate()
        self.appSessionLog?.pinInBackgroundWithName(kPMLocalDatastoreAppSessionLogPinName)
    }
    
    class func userDidLogout() {
        if (self.appSessionLog == nil) {
            return
        }
        
        self.appSessionLog?.terminateTimestamp = NSDate()
        self.appSessionLog?.saveEventually()
    }
    
    class func loadTimePlayedTodayInBackground(completion: ((timePlayedToday: NSTimeInterval) -> Void)?) {
        var timePlayedToday: NSTimeInterval = 0
        let appSessionLogLocalQuery = PMAppSessionLog.query()
        appSessionLogLocalQuery?.fromPinWithName(kPMLocalDatastoreAppSessionLogPinName)
        appSessionLogLocalQuery?.whereKey(kPMAppSessionLogUserKey, equalTo: PMUser.currentUser()!)
        appSessionLogLocalQuery?.orderByDescending(kPMAppSessionLogLaunchTimestampKey)
        appSessionLogLocalQuery?.findObjectsInBackgroundWithBlock { (localAppSessionLogs: [PFObject]?, error: NSError?) -> Void in
            if (localAppSessionLogs != nil && error == nil) {
                let appSessionLogs = localAppSessionLogs as? [PMAppSessionLog]
                var activeAppSessionLogProcessed = false
                for currentAppSessionLog: PMAppSessionLog in appSessionLogs! {
                    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                    calendar?.timeZone = NSTimeZone.localTimeZone()
                    let currentLaunchTimestampDateComponents = calendar?.components([.Day, .Month, .Year], fromDate: currentAppSessionLog.launchTimestamp)
                    let todaysDateComponents = calendar?.components([.Day, .Month, .Year], fromDate: NSDate())
                    if (currentLaunchTimestampDateComponents?.day == todaysDateComponents?.day && currentLaunchTimestampDateComponents?.month == todaysDateComponents?.month && currentLaunchTimestampDateComponents?.year == todaysDateComponents?.year) {
                        if (currentAppSessionLog.terminateTimestamp == nil) {
                            if (activeAppSessionLogProcessed == true) {
                                currentAppSessionLog.unpinInBackground()
                                continue
                            } else {
                                timePlayedToday += NSDate().timeIntervalSinceDate(currentAppSessionLog.launchTimestamp)
                                activeAppSessionLogProcessed = true
                            }
                        } else {
                            timePlayedToday += currentAppSessionLog.terminateTimestamp.timeIntervalSinceDate(currentAppSessionLog.launchTimestamp)
                        }
                        let terminateTimestamp = currentAppSessionLog.terminateTimestamp == nil ? NSDate() : currentAppSessionLog.terminateTimestamp
                        timePlayedToday += terminateTimestamp.timeIntervalSinceDate(currentAppSessionLog.launchTimestamp)
                    } else {
                        currentAppSessionLog.unpinInBackground()
                    }
                }
                completion?(timePlayedToday: timePlayedToday)
            }
        }
    }
    
}

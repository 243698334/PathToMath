//
//  AppDelegate.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

let kPMUserDefaultsLastUsernameKey = "lastUsername"
let kPMUserDefaultsLastProblemSetVersionKey = "lastProblemSetVersion"
let kPMUserDefaultsHasShownInteractionHintForCurrentGameMode = "hasInteractionHintShownForCurrentGameMode"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        PMAppSessionLog.registerSubclass()
        PMGameProgress.registerSubclass()
        PMProblem.registerSubclass()
        PMSessionPerformance.registerSubclass()
        PMProblemResponse.registerSubclass()
        PMUser.registerSubclass()
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("APPLICATION_ID_PLACEHOLDER", clientKey: "CLIENT_KEY_PLACEHOLDER")
        PFUser.enableRevocableSessionInBackground()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = PMStartupViewController()
        self.window?.makeKeyAndVisible();
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        PMAppSession.applicationWillResignActive()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        PMAppSession.applicationDidBecomeActive()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }
    
}


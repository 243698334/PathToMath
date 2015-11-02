//
//  PMConfig.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 11/1/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

let kPMConfigLegalInfoPageURLKey = "legalInfoPageURL"
let kPMConfigProblemSetVersionKey = "problemSetVersion"
let kPMConfigSupportContactEmailKey = "supportContactEmail"
let kPMConfigSupportContactNameKey = "supportContactName"
let kPMConfigLevelUpCorrectnessPercentageKey = "levelUpCorrectnessPercentageKey"

class PMConfig: PFConfig {
    
    private static let reachability = Reachability.reachabilityForInternetConnection()

    override class func initialize() {
        super.initialize()
        reachability.reachableBlock = { (let reachability: Reachability!) -> Void in
            self.getConfigInBackground()
        }
        reachability.startNotifier()
    }
    
    class func getConfigValueInBackgroundWithKey(configKey: String, completion: ((configValue: AnyObject?, error: NSError?) -> Void)?) {
        if (reachability.currentReachabilityStatus() == .NotReachable) {
            let configValue = self.getCachedConfigValueWithKey(configKey)
            completion?(configValue: configValue, error: configValue == nil ? NSError(domain: "", code: 0, userInfo: nil) : nil)
        } else {
            self.getConfigInBackgroundWithBlock({ (config: PFConfig?, error: NSError?) -> Void in
                if (config != nil && error == nil) {
                    completion?(configValue: config?.objectForKey(configKey), error: nil)
                } else {
                    completion?(configValue: nil, error: error)
                }
            })
        }
    }
    
    class func getCachedConfigValueWithKey(configKey: String) -> AnyObject? {
        return self.currentConfig().objectForKey(configKey)
    }
    
    class func cacheConfigInBackgroundWithCompletion(completion: ((success: Bool, error: NSError?) -> Void)?) {
        self.getConfigInBackgroundWithBlock { (config: PFConfig?, error: NSError?) -> Void in
            completion?(success: error != nil, error: error)
        }
    }
    
}

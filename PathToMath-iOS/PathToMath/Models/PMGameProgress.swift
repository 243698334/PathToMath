//
//  PMGameProgress.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/15/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

let kPMGameProgressClassName = "GameProgress"
let kPMGameProgressUserKey = "user"
let kPMGameProgressLevelKey = "level"

let kPMLocalDatastoreGameProgressPinName = "GameProgress"

class PMGameProgress: PFObject, PFSubclassing {
    
    @NSManaged var user: PMUser!
    @NSManaged var mode: String
    @NSManaged var level: Int
    
    class func parseClassName() -> String {
        return kPMGameProgressClassName
    }
    
}

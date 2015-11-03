//
//  PMProblem.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/20/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

let kPMProblemClassName = "Problem"
let kPMProblemLevelKey = "level"
let kPMProblemModeKey = "mode"
let kPMProblemModeBulk = "bulk"
let kPMProblemModeSingle = "single"

let kPMLocalDatastoreProblemPinName = "Problem"

class PMProblem: PFObject, PFSubclassing {
    
    @NSManaged var level: Int
    @NSManaged var firstTerm: Int
    @NSManaged var secondTerm: Int
    @NSManaged var comparisonNumber: Int
    @NSManaged var mode: String
    
    class func parseClassName() -> String {
        return kPMProblemClassName
    }
    
}

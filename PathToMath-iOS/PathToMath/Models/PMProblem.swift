//
//  PMProblem.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/20/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

let kPMProblemClassName = "Problem"
let kPMProblemLevelKey = "level"

let kPMLocalDatastoreProblemPinName = "Problem"

class PMProblem: PFObject, PFSubclassing {
    
    @NSManaged var level: Int
    @NSManaged var firstTerm: Int
    @NSManaged var secondTerm: Int
    @NSManaged var comparisonNumber: Int
    
    class func parseClassName() -> String {
        return kPMProblemClassName
    }
    
}

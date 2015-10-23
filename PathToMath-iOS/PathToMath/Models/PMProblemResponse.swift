//
//  PMProblemResponse.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/20/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

let kPMProblemResponseClassName = "ProblemResponse"

class PMProblemResponse: PFObject, PFSubclassing {

    @NSManaged var problem: PMProblem!
    @NSManaged var gameMode: String!
    @NSManaged var startTimestamp: NSDate!
    @NSManaged var finishTimestamp: NSDate!
    @NSManaged var timeElapsed: NSTimeInterval
    @NSManaged var correct: Bool
    
    class func parseClassName() -> String {
        return kPMProblemResponseClassName
    }
    
}

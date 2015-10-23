//
//  PMSessionPerformance.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

let kPMSessionPerformanceClassName = "SessionPerformance"

class PMSessionPerformance: PFObject, PFSubclassing {
    
    @NSManaged var user: PMUser!
    @NSManaged var level: Int
    @NSManaged var totalProblems: Int
    @NSManaged var correctProblems: Int
    @NSManaged var incorrectProblems: Int
    @NSManaged var responses: [PMProblemResponse]!
    
    class func parseClassName() -> String {
        return kPMSessionPerformanceClassName
    }
    
}

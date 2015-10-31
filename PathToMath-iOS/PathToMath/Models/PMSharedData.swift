//
//  PMSharedData.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 10/14/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

let kPMSharedDataClassName = "SharedData"
let kPMSharedDataKeyKey = "sharedDataKey"
let kPMSharedDataValueKey = "sharedDataValue"

let kPMSharedDataProblemSetVersionKeyKey = "problemSetVersion"
let kPMSharedDataLevelUpCorrectnessKeyKey = "levelUpCorrectness"
let kPMSharedDataSupportContactNameKeyKey = "supportContactName"
let kPMSharedDataSupportContactEmailKeyKey = "supportContactEmail"
let kPMSharedDataLegalInfoPageURLKeyKey = "legalInfoPageURL"

let kPMLocalDatastoreSharedDataPinName = "SharedData"

class PMSharedData: PFObject, PFSubclassing {
    
    @NSManaged var sharedDataKey: String
    @NSManaged var sharedDataValue: String
    
    class func parseClassName() -> String {
        return kPMSharedDataClassName
    }
    
}
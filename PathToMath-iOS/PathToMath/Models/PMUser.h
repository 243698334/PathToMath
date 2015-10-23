//
//  PMUser.h
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/20/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

#import "PFUser.h"

NSString const *kPMUserDisplayNameKey = @"displayName";
NSString const *KPMUserAgeKey = @"age";

@interface PMUser : PFUser<PFSubclassing>

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) NSInteger age;

@end

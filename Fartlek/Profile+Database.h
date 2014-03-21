//
//  Profile+Database.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Profile.h"
#import "DataManager.h"

@interface Profile (Database)

+ (NSArray *)findAll;
+ (id)findByProfileID:(NSString *)profileID;

@end

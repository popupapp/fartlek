//
//  Profile+Database.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Profile+Database.h"

@implementation Profile (Database)

+ (id)findByProfileID:(NSString *)profileID
{
    return [[DataManager sharedManager] findProfileByID:profileID];
}

+ (NSArray *)findAll
{
    return [[DataManager sharedManager] findAllProfiles];
}

@end

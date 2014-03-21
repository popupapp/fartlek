//
//  User+Database.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "User+Database.h"

@implementation User (Database)

+ (id)findByUserID:(NSString *)userID
{
    return [[DataManager sharedManager] findUserByID:userID];
}

+ (NSArray *)findAll
{
    return [[DataManager sharedManager] findAllUsers];
}

@end

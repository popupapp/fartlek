//
//  Run+Database.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Run+Database.h"

@implementation Run (Database)

+ (id)findByRunID:(NSString *)runID
{
    return [[DataManager sharedManager] findRunByID:runID];
}

+ (NSArray *)findAll
{
    return [[DataManager sharedManager] findAllRuns];
}

@end

//
//  Lap+Database.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Lap+Database.h"

@implementation Lap (Database)

+ (id)findByLapID:(NSString *)lapID
{
    return [[DataManager sharedManager] findLapByID:lapID];
}

+ (NSArray *)findAll
{
    return [[DataManager sharedManager] findAllLaps];
}


@end

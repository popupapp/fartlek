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

+ (void)deleteAll
{
    NSArray *laps = [self findAll];
    for (Lap *lap in laps) {
        [lap delete];
    }
}

-(void)delete
{
    [self deleteSuccess:nil
                failure:^(NSError *error)
     {
         NSLog(@"Failed to delete Lap:\n%@", error);
     }];
}

- (void)deleteSuccess:(void (^)(void))success
              failure:(void (^)(NSError *error))failure
{
    [[[DataManager sharedManager] managedObjectContext] deleteObject:self];
    [self saveSuccess:success failure:failure];
}

- (void)saveSuccess:(void (^)(void))success
            failure:(void (^)(NSError *error))failure
{
    NSError *error;
    [[[DataManager sharedManager] managedObjectContext] save:&error];
    if (error) {
        if (failure) failure(error);
    } else {
        if (success) success();
    }
}


@end

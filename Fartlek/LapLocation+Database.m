//
//  LapLocation+Database.m
//  Fartlek
//
//  Created by Jason Humphries on 4/7/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "LapLocation+Database.h"

@implementation LapLocation (Database)

+ (id)findByLapLocationID:(NSString *)lapLocationID
{
    return [[DataManager sharedManager] findRunByID:lapLocationID];
}

+ (NSArray *)findAll
{
    return [[DataManager sharedManager] findAllRuns];
}

+ (void)deleteAll
{
    NSArray *lapLocations = [self findAll];
    for (LapLocation *lapLoc in lapLocations) {
        [lapLoc delete];
    }
}

-(void)delete
{
    [self deleteSuccess:nil
                failure:^(NSError *error)
     {
         NSLog(@"Failed to delete LapLocation:\n%@", error);
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

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

+ (void)deleteAll
{
    NSArray *runs = [self findAll];
    for (Run *run in runs) {
        [run delete];
    }
}

-(void)delete
{
    [self deleteSuccess:nil
                failure:^(NSError *error)
     {
         NSLog(@"Failed to delete Run:\n%@", error);
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

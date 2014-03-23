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

+ (void)deleteAll
{
    NSArray *profiles = [self findAll];
    for (Profile *profile in profiles) {
        [profile delete];
    }
}

-(void)delete
{
    [self deleteSuccess:nil
                failure:^(NSError *error)
     {
         NSLog(@"Failed to delete Profile:\n%@", error);
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

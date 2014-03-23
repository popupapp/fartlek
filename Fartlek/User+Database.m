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

+ (void)deleteAll
{
    NSArray *users = [self findAll];
    for (User *user in users) {
        [user delete];
    }
}

-(void)delete
{
    [self deleteSuccess:nil
                failure:^(NSError *error)
     {
         NSLog(@"Failed to delete User:\n%@", error);
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

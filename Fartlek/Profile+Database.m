//
//  Profile+Database.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Profile+Database.h"
#import "FartlekUser.h"
#import "NSObject+Conversions.h"

@implementation Profile (Database)

// BEGIN SERVER STUFF

+ (void)createProfileWithJSONFromServer:(NSArray *)jsonArray
                             appendedTo:(NSMutableArray *)profileLaps
                                success:(void (^)(void))success
                                failure:(void (^)(NSError *))failure
{
    if (jsonArray && [jsonArray count] > 0) {
        NSDictionary *jsonForFirstProfile = jsonArray[0];
        [self createUpdateOrDeleteProfileWithJSONFromServer:jsonForFirstProfile
                                                     success:
         ^(Profile *profile) {
             if (profile) {
                 [profileLaps addObject:profile];
             }
             NSMutableArray *jsonForRemainingServices = [jsonArray mutableCopy];
             [jsonForRemainingServices removeObjectAtIndex:0];
             [self createProfileWithJSONFromServer:jsonForRemainingServices
                                        appendedTo:profileLaps
                                           success:success
                                           failure:failure];
         } failure:failure];
    } else {
        if (success) success();
    }
}

+ (void)createUpdateOrDeleteProfileWithJSONFromServer:(NSDictionary *)json
                                              success:(void (^)(Profile *profile))success
                                              failure:(void (^)(NSError *failure))failure
{
    Profile *newProfile = [self findOrCreateByID:[json[@"_id"] toString]];
    
    if (json[@"category"] && ![json[@"category"] isKindOfClass:[NSNull class]]) {
        newProfile.profileName = json[@"category"];
    }
    [newProfile saveSuccess:
     ^ {
         if (success) success(newProfile);
     } failure:failure];
}

// END SERVER STUFf

+ (void)findCreateOrUpdateProfileWithJSON:(NSDictionary *)profileJSON
                                  success:(void (^)(Profile *))success
                                  failure:(void (^)(NSError *))failure
{
    Profile *profile = [self findByProfileID:[profileJSON[@"id"] toString]];
    if (profile && success) {
        [profile updateProfileWithJSONFromServer:profileJSON
                                         success:success
                                         failure:failure];
    } else {
        Profile *profile = [[DataManager sharedManager] createProfile];
        [profile updateProfileWithJSONFromServer:profileJSON
                                         success:success
                                         failure:failure];
    }
}

- (void)updateProfileWithJSONFromServer:(NSDictionary *)json
                             success:(void (^)(Profile *))success
                             failure:(void (^)(NSError *error))failure
{
// RETURN JSON:
//    {
//        "created_at" = "2014-03-23T22:55:11.926Z";
//        duration = 40;
//        id = 4;
//        intensity = 1;
//        name = "Low 40 A";
//        "updated_at" = "2014-03-23T22:55:11.926Z";
//    }
    self.profileID = [json[@"id"] toString];
    if (json[@"duration"] && ![json[@"duration"] isKindOfClass:[NSNull class]]) {
        self.duration = json[@"duration"];
    }
    if (json[@"intensity"] && ![json[@"intensity"] isKindOfClass:[NSNull class]]) {
        self.intensity = [json[@"intensity"] toString];
    }
    if (json[@"name"] && ![json[@"name"] isKindOfClass:[NSNull class]]) {
        self.profileName = json[@"name"];
    }
    
    [self saveSuccess: ^{
        if (success) success(self);
    } failure:failure];
}

+ (Profile *)findOrCreateByID:(NSString *)profileID
{
    Profile *profile = [self findByProfileID:profileID];
    if (profile) {
        return profile;
    } else {
        profile = [self create];
        profile.profileID = profileID;
    }
    return profile;
}

+ (Profile *)create
{
    return [[DataManager sharedManager] createProfile];
}

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

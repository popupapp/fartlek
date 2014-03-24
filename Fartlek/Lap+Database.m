//
//  Lap+Database.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Lap+Database.h"
#import "Profile+Database.h"
#import "NSObject+Conversions.h"

@implementation Lap (Database)


// BEGIN SERVER STUFF

+ (void)createLapsWithGetProfileJSONFromServer:(NSArray *)jsonArray
                               withProfileJSON:(NSDictionary*)profileJSON
                                    appendedTo:(NSMutableArray *)laps
                                       success:(void (^)(void))success
                                       failure:(void (^)(NSError *))failure
{
    if (jsonArray && [jsonArray count] > 0) {
        NSDictionary *jsonForFirstLap = jsonArray[0];
        [self createUpdateOrDeleteLapWithJSONFromServer:jsonForFirstLap
                                        withProfileJSON:profileJSON
                                                    success:
         ^(Lap *lap) {
             if (lap) {
                 [laps addObject:lap];
             }
             NSMutableArray *jsonForRemainingLaps = [jsonArray mutableCopy];
             [jsonForRemainingLaps removeObjectAtIndex:0];
             [self createLapsWithGetProfileJSONFromServer:jsonForRemainingLaps
                                          withProfileJSON:profileJSON
                                               appendedTo:laps
                                                  success:success
                                                  failure:failure];
         } failure:failure];
    } else {
        if (success) success();
    }
}

+ (void)createUpdateOrDeleteLapWithJSONFromServer:(NSDictionary *)json
                                  withProfileJSON:(NSDictionary*)profileDict
                                          success:(void (^)(Lap *lap))success
                                          failure:(void (^)(NSError *failure))failure
{
    [Profile findCreateOrUpdateProfileWithJSON:profileDict
                                 success:
     ^(Profile *profile) {
         if (profile) {
             Lap *newLap = [self findOrCreateByID:[json[@"id"] toString]];
             
             if (json[@"lap_intensity"] && ![json[@"lap_intensity"] isKindOfClass:[NSNull class]]) {
                 newLap.lapIntensity = json[@"lap_intensity"];
             }
             if (json[@"lap_number"] && ![json[@"lap_number"] isKindOfClass:[NSNull class]]) {
                 newLap.lapNumber = json[@"lap_number"];
             }
             if (json[@"lap_speech_string"] && ![json[@"lap_speech_string"] isKindOfClass:[NSNull class]]) {
                 newLap.lapStartSpeechString = json[@"lap_speech_string"];
             }
             if (json[@"lap_time"] && ![json[@"lap_time"] isKindOfClass:[NSNull class]]) {
                 newLap.lapTime = json[@"lap_time"];
             }
             
             [newLap saveSuccess:
              ^ {
                  if (success) success(newLap);
              } failure:failure];
             
         } else {
             if (failure) failure([NSError errorWithDomain:@"FartlekErrorDomain" code:0
                                                  userInfo:@{@"description": [NSString stringWithFormat:@"No local profile record for request: %@", json]}]);
         }
     } failure:failure];
// RETURN JSON (EACH LAP):
//    {
//        "created_at" = "2014-03-23T22:55:11.932Z";
//        id = 53;
//        "lap_intensity" = 0;
//        "lap_number" = 1;
//        "lap_speech_string" = "Warm up slowly for five minutes. Nice and easy. Not even your Easy Run pace.\n";
//        "lap_time" = 5;
//        "profile_id" = 4;
//        "updated_at" = "2014-03-23T22:55:11.932Z";
//    }
}

// END SERVER STUFF

+ (Lap *)findOrCreateByID:(NSString *)lapID
{
    Lap *lap = [self findByLapID:lapID];
    if (lap) {
        return lap;
    } else {
        lap = [self create];
        lap.lapID = lapID;
    }
    return lap;
}

+ (Lap *)create
{
    return [[DataManager sharedManager] createLap];
}

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

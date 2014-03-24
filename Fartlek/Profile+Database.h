//
//  Profile+Database.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Profile.h"
#import "DataManager.h"

@interface Profile (Database)

+ (void)findCreateOrUpdateProfileWithJSON:(NSDictionary *)profileJSON
                                  success:(void (^)(Profile *profile))success
                                  failure:(void (^)(NSError *error))failure;

+ (void)createProfileWithJSONFromServer:(NSArray *)jsonArray
                             appendedTo:(NSMutableArray *)profileLaps
                                success:(void (^)(void))success
                                failure:(void (^)(NSError *error))failure;

- (void)saveSuccess:(void (^)(void))success
            failure:(void (^)(NSError *error))failure;

+ (NSArray *)findAll;
+ (id)findByProfileID:(NSString *)profileID;
+ (void)deleteAll;

@end

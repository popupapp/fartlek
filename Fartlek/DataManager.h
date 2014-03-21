//
//  DataManager.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;
#import "Run.h"
#import "Lap.h"
#import "User.h"
#import "Profile.h"

@interface DataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedManager;

- (void)saveContextSuccess:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure;

- (User*)findUserByID:(NSString *)userID;
- (User*)createUser;
- (NSArray*)findAllUsers;

- (Lap*)findLapByID:(NSString *)lapID;
- (Lap*)createLap;
- (NSArray*)findAllLaps;

- (Run*)findRunByID:(NSString *)runID;
- (Run*)createRun;
- (NSArray*)findAllRuns;

- (Profile*)findProfileByID:(NSString *)profileID;
- (Profile*)createProfile;
- (NSArray*)findAllProfiles;

@end

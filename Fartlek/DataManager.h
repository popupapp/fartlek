//
//  DataManager.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "Run.h"
#import "Lap.h"
#import "User.h"
#import "Profile.h"

@interface DataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) Profile *currentProfile;

+ (id)sharedManager;

- (void)saveContextSuccess:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure;

- (void)markAllProfilesAsNotCurrent;

- (User*)findUserByID:(NSString *)userID;
- (User*)createUser;
- (NSArray*)findAllUsers;

- (Lap*)findLapByID:(NSString *)lapID;
- (Lap*)createLap;
- (NSArray*)orderedLapsByLapNumber:(NSArray*)lapArray;
- (NSArray*)findAllLaps;

- (Run*)findRunByID:(NSString *)runID;
- (Run*)createRun;
- (NSArray*)findAllRuns;

- (Profile*)findProfileByID:(NSString *)profileID;
- (Profile*)findCurrentProfile;
- (Profile*)createProfile;
- (NSArray*)findAllProfiles;

@end

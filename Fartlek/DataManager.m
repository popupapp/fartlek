//
//  DataManager.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "DataManager.h"
#import "Profile+Database.h"

static DataManager *g_dataManager = nil;

@interface DataManager ()
- (NSString *)applicationDocumentsDirectory;
@end

@implementation DataManager

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (id)init
{
    if ((self = [super init])) {
    }
    return self;
}

+ (id)sharedManager
{
    if (!g_dataManager) {
        g_dataManager = [[DataManager alloc] init];
    }
    return g_dataManager;
}

- (void)saveContextSuccess:(void (^)(void))success
                   failure:(void (^)(NSError *error))failure
{
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"\n\nError saving context:\n%@\n\n", error);
        if (failure) failure(error);
    }
    else {
        if (success) success();
    }
}

- (void)handleError:(NSError *)error
{
    NSLog(@"\nError during core data query:\n%@", error);
}

- (void)markAllProfilesAsNotCurrent
{
    NSArray *allProfiles = [self findAllProfiles];
    for (Profile *p in allProfiles) {
        p.isCurrentProfile = @0;
        [p saveSuccess:nil failure:nil];
    }
}

// FETCHES

- (Profile *)findCurrentProfile
{
    NSError *error = nil;
    NSArray *senders = [self.managedObjectContext executeFetchRequest:[self requestForCurrentProfile]
                                                                error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    }
    else {
        if ([senders count] > 0) {
            return [senders objectAtIndex:0];
        } else {
            return nil;
        }
    }
}

-(NSArray *)findAllUsers
{
    NSError *error = nil;
    NSArray *allUsers = [self.managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"User"] error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    } else {
        return allUsers;
    }
}

-(User *)findUserByID:(NSString *)userID
{
    NSError *error = nil;
    NSArray *senders = [self.managedObjectContext executeFetchRequest:[self requestForUserWithID:userID]
                                                                error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    }
    else {
        if ([senders count] > 0) {
            return [senders objectAtIndex:0];
        } else {
            return nil;
        }
    }
}

-(NSArray *)findAllLaps
{
    NSError *error = nil;
    NSArray *allUsers = [self.managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Lap"]
                                                                 error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    } else {
        return allUsers;
    }
}

- (NSArray *)orderedLapsByLapNumber:(NSArray *)lapArray
{
    // sort the laps in lapArray by lap.lapNumber
    NSError *error = nil;
    NSFetchRequest *fetchPred = [NSFetchRequest fetchRequestWithEntityName:@"Lap"];
    NSSortDescriptor *sortByLapNumber = [[NSSortDescriptor alloc] initWithKey:@"lapNumber" ascending:YES];
    fetchPred.sortDescriptors = @[sortByLapNumber];
    NSArray *orderedLaps = [self.managedObjectContext executeFetchRequest:fetchPred error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    } else {
        return orderedLaps;
    }
}

-(Lap *)findLapByID:(NSString *)lapID
{
    NSError *error = nil;
    NSArray *senders = [self.managedObjectContext executeFetchRequest:[self requestForLapWithID:lapID]
                                                                error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    }
    else {
        if ([senders count] > 0) {
            return [senders objectAtIndex:0];
        } else {
            return nil;
        }
    }
}

-(NSArray *)findAllRuns
{
    NSError *error = nil;
    NSArray *allUsers = [self.managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Run"]
                                                                 error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    } else {
        return allUsers;
    }
}

-(Run *)findRunByID:(NSString *)runID
{
    NSError *error = nil;
    NSArray *senders = [self.managedObjectContext executeFetchRequest:[self requestForRunWithID:runID]
                                                                error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    }
    else {
        if ([senders count] > 0) {
            return [senders objectAtIndex:0];
        } else {
            return nil;
        }
    }
}

-(NSArray *)findAllProfiles
{
    NSError *error = nil;
    NSArray *allUsers = [self.managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"Profile"]
                                                                 error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    } else {
        return allUsers;
    }
}

-(Profile *)findProfileByID:(NSString *)profileID
{
    NSError *error = nil;
    NSArray *senders = [self.managedObjectContext executeFetchRequest:[self requestForProfileWithID:profileID]
                                                                error:&error];
    if (error) {
        [self handleError:error];
        return nil;
    }
    else {
        if ([senders count] > 0) {
            return [senders objectAtIndex:0];
        } else {
            return nil;
        }
    }
}

// CREATION

-(User *)createUser
{
    return [[User alloc] initWithEntity:[self entityForName:@"User"]
         insertIntoManagedObjectContext:self.managedObjectContext];
}

-(Lap *)createLap
{
    return [[Lap alloc] initWithEntity:[self entityForName:@"Lap"]
        insertIntoManagedObjectContext:self.managedObjectContext];
}

-(Run *)createRun
{
    return [[Run alloc] initWithEntity:[self entityForName:@"Run"]
        insertIntoManagedObjectContext:self.managedObjectContext];
}

-(Profile *)createProfile
{
    return [[Profile alloc] initWithEntity:[self entityForName:@"Profile"]
            insertIntoManagedObjectContext:self.managedObjectContext];
}


// PREDICATES

- (NSFetchRequest *)requestForEntityName:(NSString *)name withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    request.predicate = predicate;
    return request;
}

- (NSEntityDescription *)entityForName:(NSString *)name
{
    return [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
}


- (NSFetchRequest *)requestForUserWithID:(NSString*)userID
{
    return [self requestForEntityName:@"User"
                        withPredicate:[NSPredicate predicateWithFormat:@"userID == %@", userID]];
}

- (NSFetchRequest *)requestForLapWithID:(NSString*)lapID
{
    return [self requestForEntityName:@"Lap"
                        withPredicate:[NSPredicate predicateWithFormat:@"lapID == %@", lapID]];
}

- (NSFetchRequest *)requestForRunWithID:(NSString*)runID
{
    return [self requestForEntityName:@"Run"
                        withPredicate:[NSPredicate predicateWithFormat:@"runID == %@", runID]];
}

- (NSFetchRequest *)requestForProfileWithID:(NSString*)profileID
{
    return [self requestForEntityName:@"Profile"
                        withPredicate:[NSPredicate predicateWithFormat:@"profileID == %@", profileID]];
}

- (NSFetchRequest *)requestForCurrentProfile
{
    return [self requestForEntityName:@"Profile"
                        withPredicate:[NSPredicate predicateWithFormat:@"isCurrentProfile == 1"]];
}


#pragma mark - CoreData Stack Dynamic Properties

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"FartlekModel.sqlite"]];
	
	NSError *error;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:[self persistentStoreOptions] error:&error]) {
        NSLog(@"PERSISTENT STORE COORDINATOR ERROR:%@", error);
    }
	
    return _persistentStoreCoordinator;
}

- (NSDictionary *)persistentStoreOptions
{
    return @{ NSMigratePersistentStoresAutomaticallyOption: @(YES),
              NSInferMappingModelAutomaticallyOption: @(YES) };
}

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}



@end

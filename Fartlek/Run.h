//
//  Run.h
//  Fartlek
//
//  Created by Jason Humphries on 4/7/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lap, Profile, User;

@interface Run : NSManagedObject

@property (nonatomic, retain) NSString * runID;
@property (nonatomic, retain) NSNumber * runDistance;
@property (nonatomic, retain) NSNumber * runPace;
@property (nonatomic, retain) Profile *profile;
@property (nonatomic, retain) NSSet *runLaps;
@property (nonatomic, retain) User *user;
@end

@interface Run (CoreDataGeneratedAccessors)

- (void)addRunLapsObject:(Lap *)value;
- (void)removeRunLapsObject:(Lap *)value;
- (void)addRunLaps:(NSSet *)values;
- (void)removeRunLaps:(NSSet *)values;

@end

//
//  Profile.h
//  Fartlek
//
//  Created by Jason Humphries on 4/7/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lap, Run;

@interface Profile : NSManagedObject

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * intensity;
@property (nonatomic, retain) NSNumber * isCurrentProfile;
@property (nonatomic, retain) NSString * profileID;
@property (nonatomic, retain) NSString * profileName;
@property (nonatomic, retain) NSNumber * versionNumber;
@property (nonatomic, retain) NSSet *runs;
@property (nonatomic, retain) NSSet *laps;
@end

@interface Profile (CoreDataGeneratedAccessors)

- (void)addRunsObject:(Run *)value;
- (void)removeRunsObject:(Run *)value;
- (void)addRuns:(NSSet *)values;
- (void)removeRuns:(NSSet *)values;

- (void)addLapsObject:(Lap *)value;
- (void)removeLapsObject:(Lap *)value;
- (void)addLaps:(NSSet *)values;
- (void)removeLaps:(NSSet *)values;

@end

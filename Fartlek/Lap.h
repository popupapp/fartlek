//
//  Lap.h
//  Fartlek
//
//  Created by Jason Humphries on 4/7/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LapLocation, Profile, Run;

@interface Lap : NSManagedObject

@property (nonatomic, retain) NSString * lapID;
@property (nonatomic, retain) NSNumber * lapIntensity;
@property (nonatomic, retain) NSNumber * lapNumber;
@property (nonatomic, retain) NSString * lapStartSpeechString;
@property (nonatomic, retain) NSNumber * lapTime;
@property (nonatomic, retain) NSNumber * lapPace;
@property (nonatomic, retain) NSNumber * lapDistance;
@property (nonatomic, retain) Run *lapRun;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) Profile *profile;
@end

@interface Lap (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(LapLocation *)value;
- (void)removeLocationsObject:(LapLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end

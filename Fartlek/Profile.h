//
//  Profile.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Profile : NSManagedObject

@property (nonatomic, retain) NSString * profileID;
@property (nonatomic, retain) NSString * profileName;
@property (nonatomic, retain) NSString * intensity;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSSet *runs;
@property (nonatomic, retain) NSSet *laps;
@end

@interface Profile (CoreDataGeneratedAccessors)

- (void)addRunsObject:(NSManagedObject *)value;
- (void)removeRunsObject:(NSManagedObject *)value;
- (void)addRuns:(NSSet *)values;
- (void)removeRuns:(NSSet *)values;

- (void)addLapsObject:(NSManagedObject *)value;
- (void)removeLapsObject:(NSManagedObject *)value;
- (void)addLaps:(NSSet *)values;
- (void)removeLaps:(NSSet *)values;

@end

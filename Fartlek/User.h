//
//  User.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *runs;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addRunsObject:(NSManagedObject *)value;
- (void)removeRunsObject:(NSManagedObject *)value;
- (void)addRuns:(NSSet *)values;
- (void)removeRuns:(NSSet *)values;

@end

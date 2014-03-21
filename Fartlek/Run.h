//
//  Run.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile, User;

@interface Run : NSManagedObject

@property (nonatomic, retain) NSString * runID;
@property (nonatomic, retain) Profile *profile;
@property (nonatomic, retain) User *user;

@end

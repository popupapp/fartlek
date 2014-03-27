//
//  RunManager.h
//  Fartlek
//
//  Created by Jason Humphries on 3/25/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@class Profile, Lap;

@interface RunManager : NSObject

+ (RunManager*)sharedManager;
- (void)resetManager;

@property (strong, nonatomic) Profile *currentProfile;
@property (strong, nonatomic) Lap *currentLap;

@end

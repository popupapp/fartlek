//
//  RunManager.h
//  Fartlek
//
//  Created by Jason Humphries on 3/25/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol RunManagerDelegate <NSObject>
- (void)runDidBegin;
- (void)lapDidBegin:(int)lapNumber;
- (void)timerDidFire;
@end

@class Profile, Lap;

@interface RunManager : NSObject

+ (RunManager*)sharedManager;
- (void)resetManager;
- (void)startRun;
- (float)progressOfRun;

@property (nonatomic, strong) id <RunManagerDelegate> delegate;
@property (assign, nonatomic) int currentLapSecondsTotal;
@property (assign, nonatomic) int currentProfileSecondsElapsed;
@property (strong, nonatomic) Profile *currentProfile;
@property (strong, nonatomic) Lap *currentLap;
@property (strong, nonatomic) NSTimer *currentTimer;

@end

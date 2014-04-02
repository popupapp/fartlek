//
//  RunManager.h
//  Fartlek
//
//  Created by Jason Humphries on 3/25/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <FlurrySDK/Flurry.h>

@protocol RunManagerDelegate <NSObject>
- (void)runDidBegin;
- (void)runDidPause;
- (void)runDidResume;
- (void)lapDidBegin:(int)lapNumber;
- (void)timerDidFire;
@end

@class Profile, Lap, FartlekChartView;

@interface RunManager : NSObject

@property (nonatomic, strong) id <RunManagerDelegate> delegate;
+ (RunManager*)sharedManager;
- (void)resetManager;
- (void)startRun;
- (void)pauseRun;
- (float)progressOfRun;
- (int)secondsLeftInRun;
- (int)secondsLeftInLap;
- (int)secondsElapsedInLap;
- (int)secondsElapsedInRun;
- (FartlekChartView*)chartViewForProfileCanEdit:(BOOL)canEdit;

@property (strong, nonatomic) NSNumber *userPaceMinutes;
@property (strong, nonatomic) NSNumber *userPaceSeconds;
@property (strong, nonatomic) NSNumber *userIntensity;
@property (strong, nonatomic) NSNumber *userDuration;

@property (assign, nonatomic) BOOL isPaused;
@property (assign, nonatomic) int currentLapSecondsTotal;
@property (assign, nonatomic) int currentProfileSecondsElapsed;
@property (strong, nonatomic) Profile *currentProfile;
@property (strong, nonatomic) Lap *currentLap;
@property (strong, nonatomic) NSTimer *currentTimer;

@end

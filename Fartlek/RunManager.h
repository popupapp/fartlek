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

@class Profile, Lap, FartlekChartView, Run;

@interface RunManager : NSObject

@property (nonatomic, weak) id <RunManagerDelegate> delegate;
+ (RunManager*)sharedManager;
- (void)resetManager;
- (void)startRun;
- (void)saveAndStopRun;
- (void)pauseRun;
- (float)progressOfRun;
- (float)currentPaceOfRun;
- (float)currentPaceOfLap;
- (int)secondsLeftInRun;
- (int)secondsLeftInLap;
- (int)secondsElapsedInLap;
- (int)secondsElapsedInRun;
- (FartlekChartView*)chartViewForProfileCanEdit:(BOOL)canEdit;
- (void)addLocationToRun:(CLLocation*)location;

@property (strong, nonatomic) NSMutableArray *runLocationsForDistanceCalculations;
@property (strong, nonatomic) NSMutableArray *runLocations;

@property (strong, nonatomic) NSNumber *userPaceMinutes;
@property (strong, nonatomic) NSNumber *userPaceSeconds;
@property (strong, nonatomic) NSNumber *userIntensity;
@property (strong, nonatomic) NSNumber *userDuration;

@property (assign, nonatomic) BOOL isPaused;
@property (strong, nonatomic) Profile *currentProfile;
@property (strong, nonatomic) Run *currentRun;
@property (strong, nonatomic) Lap *currentLap;
@property (strong, nonatomic) NSTimer *currentTimer;

@property (assign, nonatomic) int currentLapSecondsTotal;
@property (assign, nonatomic) int currentRunSecondsElapsed;
@property (assign, nonatomic) float currentLapDistanceTotal;
@property (assign, nonatomic) float currentRunDistanceTotal;

@end

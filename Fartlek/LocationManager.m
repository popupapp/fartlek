//
//  LocationManager.m
//  Fartlek
//
//  Created by Jason Humphries on 4/4/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "LocationManager.h"
#import "AppDelegate.h"
#import "Profile+Database.h"
#import "Lap+Database.h"
#import "RunManager.h"

static LocationManager *g_locationManager;

@interface LocationManager ()
@property (strong, nonatomic) NSTimer *locationTimer;
@property (assign, nonatomic) BOOL deferringUpdates;
@property (strong, nonatomic) NSTimer *keepAliveTimer;
@end

@implementation LocationManager

- (id)init
{
    if ((self = [super init])) {
        //
    }
    return self;
}

+ (LocationManager *)sharedManager
{
    if (!g_locationManager) {
        g_locationManager = [[self alloc] init];
    }
    return g_locationManager;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager && [self locationServicesEnabledAndAvailable]) {
        self.locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (BOOL)locationServicesEnabledAndAvailable
{
    if (![CLLocationManager locationServicesEnabled]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to start location updates" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return NO;
    } else {
        return YES;
    }
}

- (void)stopLocationUpdates
{
    self.isUpdatingLocation = NO;
    [self.locationManager stopUpdatingLocation];
}

- (void)restartStandardLocationCheck
{
    self.numberOfLocationUpdates = 0;
    [self continueOrStartStandardLocationCheck];
}

- (void)continueOrStartStandardLocationCheck
{
    if (!self.isUpdatingLocation) {
        self.isUpdatingLocation = YES;
        self.deferringUpdates = NO;
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.activityType = CLActivityTypeFitness;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // setting this to NO is super important to have the lap exist longer in the background
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        [self.locationManager startUpdatingLocation];
        NSLog(@"-> start updating location");
    } else {
        NSLog(@"-> is already updating location");
    }
}

-(void)locationManager:(CLLocationManager *)manager
    didUpdateLocations:(NSArray *)locations
{
    self.numberOfLocationUpdates += 1;
    CLLocation *lastLocation = [locations lastObject];
    [[RunManager sharedManager] addLocationToRun:lastLocation];
    self.currentLocation = lastLocation;
    
    [self resetKeepAliveTimer];
    
    // Defer updates until the user runs a certain distance
    // or when a certain amount of time has passed.
    NSLog(@"got a location (%f)", lastLocation.horizontalAccuracy);
    if (!self.deferringUpdates) {
        Lap *currentLap = [[RunManager sharedManager] currentLap];
        if (currentLap) {
            //            CLLocationDistance distance = 100.f;
            NSTimeInterval time = [[RunManager sharedManager] secondsLeftInLap];
            NSLog(@"setting allowDeferredLocationUpdates (time:%d)", (int)time);
            [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax
                                                                    timeout:time];
            self.deferringUpdates = YES;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    self.deferringUpdates = NO;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Location Manager Failure: %@", error);
}

- (void)resetKeepAliveTimer
{
    if (!self.keepAliveTimer) {
        NSLog(@"scheduled keepAliveTimerDidFire");
        self.keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:590
                                                               target:self
                                                             selector:@selector(keepAliveTimerDidFire:)
                                                             userInfo:nil
                                                              repeats:NO];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.keepAliveTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)keepAliveTimerDidFire:(NSTimer*)timer
{
    NSLog(@"keepAliveTimerDidFire");
    [self continueOrStartStandardLocationCheck];
    self.keepAliveTimer = nil;
    [self resetKeepAliveTimer];
}




@end

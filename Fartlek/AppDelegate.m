//
//  AppDelegate.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <TestFlightSDK/TestFlight.h>
#import <Bestly/Bestly.h>
#import "Profile+Database.h"
#import "Lap+Database.h"
#import "RunManager.h"

@interface AppDelegate ()
@property (assign, nonatomic) BOOL deferringUpdates;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *keepAliveTimer;
@property (assign, nonatomic) BOOL isUpdatingLocation;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.isUpdatingLocation = NO;
    
    // FRAMEWORKS
    [Bestly setupWithKey:BESTLY_KEY];
    [TestFlight takeOff:TESTFLIGHT_TOKEN];
    
    [self continueOrStartLocationUpdating];
//    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
//        NSLog(@"local notif app did finish launching");
//    }
    
    return YES;
}

// LOCATION

- (void)continueOrStartLocationUpdating
{
    // LOCATION
    if (!self.isUpdatingLocation) {
        self.isUpdatingLocation = YES;
        self.deferringUpdates = NO;
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.activityType = CLActivityTypeFitness;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    //    self.locationManager.activityType = CLActivityTypeOther;
    //    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
#warning START LOCATION UPDATES HERE
        [self.locationManager startUpdatingLocation];
        NSLog(@"->start updating location");
    } else {
        NSLog(@"->is already updating location");
    }

}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // Add the new locations to the hike
//    [self.hike addLocations:locations];
    
    [self resetKeepAliveTimer];
    
    // Defer updates until the user hikes a certain distance
    // or when a certain amount of time has passed.
//    NSLog(@"got a location: %@", locations[0]);
#warning CURRENTLY NOT USING DEFERRED UPDATES
//    if (!self.deferringUpdates) {
//        Lap *currentLap = [[RunManager sharedManager] currentLap];
//        if (currentLap) {
//            CLLocationDistance distance = 100.f; // self.hike.goal - self.hike.distance;
//            NSTimeInterval time = [currentLap.lapTime intValue] * 60.0; // [self.nextAudible timeIntervalSinceNow];
//            [self.locationManager allowDeferredLocationUpdatesUntilTraveled:distance
//                                                                    timeout:time];
//            self.deferringUpdates = YES;
//        }
//    }
}

- (void)resetKeepAliveTimer
{
    if (self.keepAliveTimer) {
//        [self.keepAliveTimer invalidate];
    } else {
        NSLog(@"scheduled keepAliveTimerDidFire");
        self.keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:599
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
    [self continueOrStartLocationUpdating];
    self.keepAliveTimer = nil;
    [self resetKeepAliveTimer];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    self.deferringUpdates = NO;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"didReceiveLocalNotification:%@", notification);
    NSLog(@"didReceiveLocalNotification:%@", notification);
}

//
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

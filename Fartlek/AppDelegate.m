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

@interface AppDelegate ()
@property (assign, nonatomic) BOOL deferringUpdates;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // FRAMEWORKS
    [Bestly setupWithKey:BESTLY_KEY];
    [TestFlight takeOff:TESTFLIGHT_TOKEN];
    
    // LOCATION
    self.deferringUpdates = NO;
    self.locationManager = [CLLocationManager new];
    self.locationManager.activityType = CLActivityTypeFitness;
    [self.locationManager startUpdatingLocation];
    
    return YES;
}

// LOCATION

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // Add the new locations to the hike
//    [self.hike addLocations:locations];
    
    // Defer updates until the user hikes a certain distance
    // or when a certain amount of time has passed.
    if (!self.deferringUpdates) {
        CLLocationDistance distance = 100.f; // self.hike.goal - self.hike.distance;
        NSTimeInterval time = 60.f; // [self.nextAudible timeIntervalSinceNow];
        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:distance
                                                           timeout:time];
        self.deferringUpdates = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    self.deferringUpdates = NO;
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

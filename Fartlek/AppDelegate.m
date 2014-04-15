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
#import <FlurrySDK/Flurry.h>
#import "LocationManager.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // FRAMEWORKS
    [Bestly setupWithKey:BESTLY_KEY];
    [TestFlight takeOff:TESTFLIGHT_TOKEN];
    [Flurry startSession:FLURRY_KEY];
    
//    for (NSString *family in [UIFont familyNames]) {
//        NSLog(@"Family: %@", family);
//        for (NSString *font in [UIFont fontNamesForFamilyName:family]) {
//            NSLog(@"  => Font: %@", font);
//        }
//    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
//    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
//        NSLog(@"local notif app did finish launching");
//    }
    
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"didReceiveLocalNotification:%@", notification);
}

@end

//
//  LocationManager.h
//  Fartlek
//
//  Created by Jason Humphries on 4/4/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (LocationManager *)sharedManager;

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) int numberOfLocationUpdates;
@property (nonatomic, assign) BOOL isUpdatingLocation;

- (void)restartStandardLocationCheck;
- (void)stopLocationUpdates;

@end

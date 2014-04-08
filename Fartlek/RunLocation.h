//
//  RunLocation.h
//  Fartlek
//
//  Created by Jason Humphries on 4/7/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import MapKit;

@interface RunLocation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, strong) NSNumber * altitude;
@property (nonatomic, strong) NSNumber * horizAcc;
@property (nonatomic, strong) NSNumber * lapLocationID;
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lng;
@property (nonatomic, strong) NSDate * timestamp;
//@property (nonatomic, strong) Lap *lap;

@end

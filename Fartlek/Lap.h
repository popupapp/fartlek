//
//  Lap.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile;

@interface Lap : NSManagedObject

@property (nonatomic, retain) NSString * lapID;
@property (nonatomic, retain) NSNumber * lapNumber;
@property (nonatomic, retain) NSNumber * lapTime;
@property (nonatomic, retain) NSNumber * lapIntensity;
@property (nonatomic, retain) NSString * lapStartSpeechString;
@property (nonatomic, retain) Profile *profile;

@end

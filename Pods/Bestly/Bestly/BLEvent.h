//
//  BLEvent.h
//  BestlyExample
//
//  Created by James Martinez on 1/17/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLEvent : NSObject

+ (void)postVariationEventWithVariationID:(NSString *)variationID;
+ (void)postEvent:(NSString *)eventName withProperties:(NSDictionary *)properties;

@end

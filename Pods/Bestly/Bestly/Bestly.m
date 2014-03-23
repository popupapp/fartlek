//
//  Bestly.m
//  Bestly
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "Bestly.h"

#import "BLAPIConnectionManager.h"
#import "BLEvent.h"
#import "BLExperiment.h"
#import "BLPerson.h"
#import "BLPropertyCollectionManager.h"

@implementation Bestly

+ (void)setupWithKey:(NSString *)key {
    NSParameterAssert(key);
    [BLAPIConnectionManager setupWithKey:key];
    [BLPropertyCollectionManager collectDeviceProperties];
    [BLExperiment getExperiments];
}

+ (void)runExperimentWithID:(NSString *)experimentID
                          A:(void(^)(void))a
                          B:(void(^)(void))b {
    NSParameterAssert(experimentID);
    NSParameterAssert(a);
    NSParameterAssert(b);
    [BLExperiment runExperimentWithID:experimentID
                               blocks:@[[a copy], [b copy]]];
}

+ (void)runExperimentWithID:(NSString *)experimentID
                          A:(void(^)(void))a
                          B:(void(^)(void))b
                          C:(void(^)(void))c {
    NSParameterAssert(experimentID);
    NSParameterAssert(a);
    NSParameterAssert(b);
    NSParameterAssert(c);
    [BLExperiment runExperimentWithID:experimentID
                               blocks:@[[a copy], [b copy], [c copy]]];
}

+ (void)trackEvent:(NSString *)eventName
    withProperties:(NSDictionary *)properties {
    NSParameterAssert(eventName);
    [BLEvent postEvent:eventName withProperties:properties];
}

+ (void)addAliasToCurrentUser:(NSString *)alias {
    [BLPerson addAlias:alias toPersonWithAlias:[BLPerson manager].alias];
}

+ (void)identifyCurrentUserAs:(NSString *)alias {
    [[BLPerson manager] setAlias:alias];
}

@end

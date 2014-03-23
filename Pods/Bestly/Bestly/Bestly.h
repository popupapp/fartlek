//
//  Bestly.h
//  Bestly
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Main interface for interfacing with Bestly. Provides methods to
 run experiments and send events.
 */
@interface Bestly : NSObject

/**
 Call this in your application delegate's
 application:didFinishLaunchingWithOptions: method to setup
 the Bestly library.

 @param key Your application's API key.
 */
+ (void)setupWithKey:(NSString *)key;

/**
 Call this whenever you'd like to run an experiment.

 @param experimentID The experiment ID corresposding to the
 experiment that you'd like to run.

 @param a Experiment variation A. This is the baseline
 variation. Please note that in any sort of failure
 (e.g. lack of internet connectivity),
 this will be the variation that is run.

 @param b Experiment variation B.
 */
+ (void)runExperimentWithID:(NSString *)experimentID
                          A:(void(^)(void))a
                          B:(void(^)(void))b;

/**
 Call this whenever you'd like to run an experiment.
 @param experimentID The experiment ID corresposding to the
 experiment that you'd like to run.

 @param a Experiment variation A. This is the baseline
 variation. Please note that in any sort of failure
 (e.g. lack of internet connectivity),
 this will be the variation that is run.

 @param b Experiment variation B.

 @param c Experiment variation C.
 */
+ (void)runExperimentWithID:(NSString *)experimentID
                          A:(void(^)(void))a
                          B:(void(^)(void))b
                          C:(void(^)(void))c;

/**
 Call this when the user has performed any event that you would
 like to track.

 @param name Event name.

 @param properties Any custom properties that you would like to
 attach to the event.
 */
+ (void)trackEvent:(NSString *)eventName
    withProperties:(NSDictionary *)properties;

/**
 Call this to add an alias to the current user. This should only
 be called once per alias during the lifetime of the user across
 all platforms.

 @param alias New alias.
 */
+ (void)addAliasToCurrentUser:(NSString *)alias;

/**
 Call this to identify the current user as a known alias. This
 is not what you want to call if you want to add a new alias.

 @param alias Known alias.
 */
+ (void)identifyCurrentUserAs:(NSString *)alias;

@end

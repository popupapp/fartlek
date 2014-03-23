//
//  BLEvent.m
//  BestlyExample
//
//  Created by James Martinez on 1/17/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "BLEvent.h"

#import "BLAPIConnectionManager.h"
#import "BLPerson.h"
#import "BLPropertyCollectionManager.h"
#import "NSDictionary+PruneNull.h"

NSString *const kBestlyEventsEndpoint = @"http://best.ly/api/v1/people/%@/events";

@implementation BLEvent

+ (void)postVariationEventWithVariationID:(NSString *)variationID {
    NSParameterAssert(variationID);
    NSDictionary *standardProperties = [BLPropertyCollectionManager manager].properties;
    NSDictionary *parameters = @{ @"events": @[ @{ @"variation_id": variationID, @"properties": [standardProperties withoutNullObjects] } ] };
    [[BLAPIConnectionManager manager] POST:[NSString stringWithFormat:kBestlyEventsEndpoint, [BLPerson manager].alias]
                                parameters:parameters
                                completion:^(NSDictionary *response, NSError *error) {
                                    if (error)
                                        NSLog(@"Bestly Error: %@", error.description);
                                    else
                                        NSLog(@"Bestly - Variation event posted.");
                                }];
}

+ (void)postEvent:(NSString *)eventName withProperties:(NSDictionary *)properties {
    NSParameterAssert(eventName);
    NSDictionary *totalProperties = [NSDictionary dictionary];
    if (properties.count) {
        NSMutableDictionary *mutableProperties = [properties mutableCopy];
        NSDictionary *standardProperties = [BLPropertyCollectionManager manager].properties;
        [mutableProperties addEntriesFromDictionary:standardProperties];
        totalProperties = [mutableProperties copy];
    } else {
        totalProperties = [BLPropertyCollectionManager manager].properties;
    }
    NSDictionary *parameters = @{ @"events": @[ @{ @"name": eventName, @"properties": [[totalProperties copy] withoutNullObjects] } ] };
    [[BLAPIConnectionManager manager] POST:[NSString stringWithFormat:kBestlyEventsEndpoint, [BLPerson manager].alias]
                                parameters:parameters
                                completion:^(NSDictionary *response, NSError *error) {
                                    if (error)
                                        NSLog(@"Bestly Error: %@", error.description);
                                    else
                                        NSLog(@"Bestly - Event posted.");
                                }];
}

@end

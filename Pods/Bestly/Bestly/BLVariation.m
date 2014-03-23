//
//  BLVariation.m
//  BestlyExample
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "BLVariation.h"

#import "BLExperiment.h"

@implementation BLVariation

- (id)initWithDictionary:(NSDictionary *)dictionary
           andExperiment:(BLExperiment *)experiment {
    self = [self init];
    if (self) {
        _id = dictionary[@"id"];
        _experiment = experiment;
        _status = dictionary[@"status"];
        _weight = dictionary[@"weight"];
        _number = dictionary[@"number"];
    }
    return self;
}

@end

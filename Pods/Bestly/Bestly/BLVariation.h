//
//  BLVariation.h
//  BestlyExample
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLExperiment;

@interface BLVariation : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) BLExperiment *experiment;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *number;

- (id)initWithDictionary:(NSDictionary *)dictionary
           andExperiment:(BLExperiment *)experiment;
@end

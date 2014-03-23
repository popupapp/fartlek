//
//  BLExperiment.h
//  Bestly
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLExperiment : NSObject

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSArray *variations;

+ (void)getExperiments;

+ (void)runExperimentWithID:(NSString *)experimentID
                     blocks:(NSArray *)blocks;

@end

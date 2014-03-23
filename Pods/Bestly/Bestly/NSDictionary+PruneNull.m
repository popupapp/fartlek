//
//  NSDictionary+PruneNull.m
//  BestlyExample
//
//  Created by James Martinez on 1/17/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "NSDictionary+PruneNull.h"

@implementation NSDictionary (PruneNull)

- (NSDictionary *)withoutNullObjects {
    NSMutableDictionary *mutableSelf = [self mutableCopy];
    NSArray *nullObjectKeys = [mutableSelf allKeysForObject:[NSNull null]];
    [mutableSelf removeObjectsForKeys:nullObjectKeys];
    return [mutableSelf copy];
}

@end

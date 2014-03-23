//
//  BLPropertyCollectionManager.h
//  BestlyExample
//
//  Created by James Martinez on 1/17/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLPropertyCollectionManager : NSObject

@property (readonly, nonatomic, strong) NSDictionary *properties;

+ (instancetype)manager;
+ (void)collectDeviceProperties;

@end

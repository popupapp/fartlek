//
//  BLAPIConnectionManager.h
//  Bestly
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLAPIConnectionManager : NSObject

+ (instancetype)manager;

+ (void)setupWithKey:(NSString *)key;

- (void)GET:(NSString *)URLString
 parameters:(NSDictionary *)parameters
 completion:(void (^)(NSDictionary *response, NSError *error))completion;

- (void)POST:(NSString *)URLString
  parameters:(NSDictionary *)parameters
  completion:(void (^)(NSDictionary *response, NSError *error))completion;

@end

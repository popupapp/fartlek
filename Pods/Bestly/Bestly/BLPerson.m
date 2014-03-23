//
//  BLPerson.m
//  BestlyExample
//
//  Created by James Martinez on 1/17/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "BLPerson.h"

#import "BLAPIConnectionManager.h"

NSString *const kBestlyAliasEndpoint = @"http://best.ly/api/v1/people/%@/aliases";
NSString *const kBestlyUserDefaultsAliasKey = @"com.bestly.bestly.alias";

@implementation BLPerson

- (id)init {
    self = [super init];
    if (self) {
        _alias = [BLPerson determineAlias];
    }
    return self;
}

+ (instancetype)manager {
    static BLPerson *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

+ (NSString *)determineAlias {
    NSString *alias = nil;
    alias = [[NSUserDefaults standardUserDefaults] objectForKey:kBestlyUserDefaultsAliasKey];
    if (!alias)
        alias = [[UIDevice currentDevice].identifierForVendor UUIDString];
    if (!alias) // Fallback UUID
        alias = [[NSUUID UUID] UUIDString];
    if (!alias) { // Super fallback randomly generated string
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        NSMutableString *randomString = [NSMutableString stringWithCapacity:32];
        for (int i = 0; i < 32; i++) {
            [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
        }
        return randomString;
    }
    return alias;
}

- (void)setAlias:(NSString *)alias {
    if (alias) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:alias forKey:kBestlyUserDefaultsAliasKey];
        [userDefaults synchronize];
        _alias = alias;
    }
}

+ (void)addAlias:(NSString *)alias toPersonWithAlias:(NSString *)oldAlias {
    if (alias) {
        NSDictionary *parameters = @{ @"aliases": @[ @{ @"value": alias } ] };
        [[BLAPIConnectionManager manager] POST:[NSString stringWithFormat:kBestlyAliasEndpoint, oldAlias]
                                    parameters:parameters
                                    completion:^(NSDictionary *response, NSError *error) {
                                        if (error)
                                            NSLog(@"Bestly Error: %@", error.description);
                                        else {
                                            NSLog(@"Bestly - Alias added to the current user.");
                                            [[self manager] setAlias:alias];
                                        }
                                    }];
    }
}

@end

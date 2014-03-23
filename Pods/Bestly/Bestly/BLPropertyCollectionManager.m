//
//  BLPropertyCollectionManager.m
//  BestlyExample
//
//  Created by James Martinez on 1/17/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "BLPropertyCollectionManager.h"

#include <sys/sysctl.h>

NSString *const kBestlyLibraryVersion = @"1.1.1";

@interface BLPropertyCollectionManager ()

@property (nonatomic, strong) NSDictionary *properties;

@end

@implementation BLPropertyCollectionManager

+ (instancetype)manager {
    static BLPropertyCollectionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

+ (void)collectDeviceProperties {
    UIDevice *device = [UIDevice currentDevice];
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties setObject:[self deviceModel] forKey:@"model"];
    [properties setObject:@"iOS" forKey:@"os"];
    [properties setObject:[device systemVersion] forKey:@"os_version"];
    [properties setObject:kBestlyLibraryVersion forKey:@"lib_version"];
    [properties setObject:[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] forKey:@"app_version"];
    [properties setObject:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:@"app_release"];
    [[self manager] setProperties:[properties copy]];
}

+ (NSString *)deviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char model[size];
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *results = @(model);
    return results;
}

@end

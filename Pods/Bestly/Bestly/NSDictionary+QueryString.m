//
//  NSDictionary+QueryString.m
//  Bestly
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "NSDictionary+QueryString.h"

#import "NSString+URLEncoding.h"

@implementation NSDictionary (QueryString)

- (NSString *)queryString {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [self keyEnumerator]) {
        id value = [self objectForKey:key];
        NSString *escapedKey = [key URLEncodedString];
        NSString *escapedValue = [value URLEncodedString];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

@end

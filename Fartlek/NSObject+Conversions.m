//
//  NSObject+Conversions.m
//  Veluxe
//
//  Created by Jason Humphries on 2/17/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "NSObject+Conversions.h"
#import "NSDate+Formatting.h"

@implementation NSObject (Conversions)
- (NSNumber *)toNumber { return nil; }
- (NSString *)toString { return nil; }
- (NSDate *)toDate { return nil; }
@end

@implementation NSString (Conversions)
- (NSNumber *)toNumber { return nil; }
- (NSString *)toString { return self; }
- (NSDate *)toDate { return [NSDate dateWithRailsDateString:self]; }
@end

@implementation NSNumber (Conversions)
- (NSNumber *)toNumber { return self; }
- (NSString *)toString { return [NSString stringWithFormat:@"%@", self]; }
- (NSDate *)toDate { return [NSDate dateWithTimeIntervalSince1970:self.doubleValue]; }
@end

@implementation NSDate (Conversions)
- (NSNumber *)toNumber { return [NSNumber numberWithDouble:[self timeIntervalSince1970]]; }
- (NSString *)toString { return [self toRailsDateString]; }
- (NSDate *)toDate { return self; }
@end
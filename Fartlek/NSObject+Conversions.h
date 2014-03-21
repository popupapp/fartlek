//
//  NSObject+Conversions.h
//  Veluxe
//
//  Created by Jason Humphries on 2/17/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Conversions)
- (NSNumber *)toNumber;
- (NSString *)toString;
- (NSDate *)toDate;
@end

@interface NSString (Conversions)
- (NSNumber *)toNumber;
- (NSString *)toString;
- (NSDate *)toDate;
@end

@interface NSNumber (Conversions)
- (NSNumber *)toNumber;
- (NSString *)toString;
- (NSDate *)toDate;
@end

@interface NSDate (Conversions)
- (NSNumber *)toNumber;
- (NSString *)toString;
- (NSDate *)toDate;
@end
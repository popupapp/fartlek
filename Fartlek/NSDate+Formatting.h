//
//  NSDate+Formatting.h
//  Veluxe
//
//  Created by Jason Humphries on 2/17/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatting)
+ (NSDate *)epochDate;
+ (NSDateFormatter *)railsDateFormatter;
+ (NSDate *)dateWithRailsDateString:(NSString *)dateString;
- (NSString *)shortDateString;
- (NSString *)dateAndTimeString;
- (NSString *)toRailsDateString;
@end

//
//  NSDate+Formatting.m
//  Veluxe
//
//  Created by Jason Humphries on 2/17/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)

- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat
{
    return [self formattedStringUsingFormat:dateFormat inTimeZone:nil];
}

-(NSString*)formattedStringUsingFormat:(NSString *)dateFormat inTimeZone:(NSTimeZone *)timeZone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    if (timeZone) formatter.timeZone = timeZone;
    NSString *ret = [formatter stringFromDate:self];
    return ret;
    
}

- (NSString*)formattedDateRelativeToNow {
    
    NSString *time = [self formattedStringUsingFormat:@"h:mm a"];
    NSString *dayOfWeek = [self formattedStringUsingFormat:@"cccc"];
    
    int delta = -(int)[self timeIntervalSinceNow];
    
    if (delta < 60)
        return @"Just Now";
    if (delta < 120)
        return @"One Minute Ago";
    if (delta < 2700)
        return [NSString stringWithFormat:@"%i Minutes Ago", delta/60];
    if (delta < 5400)
        return @"An Hour Ago";
    if (delta < 24 * 3600)
        return [NSString stringWithFormat:@"%i Hours Ago", delta/3600];
    if (delta < 48 * 3600)
        return [NSString stringWithFormat:@"Yesterday at %@", time];
    if (delta < 30 * 7 * 3600) {
        return [NSString stringWithFormat:@"%@ at %@", dayOfWeek, time];
    }
    
    // Default
    return [self formattedStringUsingFormat:@"MMM d' at 'h:mm a"];
}

+ (NSDate *)epochDate
{
    return [[NSDate alloc] initWithTimeIntervalSince1970:0];
}

+ (NSDateFormatter *)railsDateFormatter
{
    NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc]
                                initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    }
    return dateFormatter;
}

+ (NSDate *)dateWithRailsDateString:(NSString *)dateString
{
    return [[self railsDateFormatter] dateFromString:dateString];
}

- (NSString *)shortDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dateAndTimeString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    return [dateFormatter stringFromDate:self];
}

- (NSString *)toRailsDateString
{
    return [[NSDate railsDateFormatter] stringFromDate:self];
}

@end

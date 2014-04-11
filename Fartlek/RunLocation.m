//
//  RunLocation.m
//  Fartlek
//
//  Created by Jason Humphries on 4/7/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "RunLocation.h"
#import "Lap+Database.h"

@implementation RunLocation

#pragma mark - MKAnnotation

- (NSString *)title
{
    return nil;
}

- (NSString *)subtitle
{
    return nil;
}

-(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.lat floatValue], [self.lng floatValue]);
}

- (NSString *)description
{
    NSString *desc = [NSString stringWithFormat:@"RunLocation:[%.3f,%.3f] (%@)", [self.lat floatValue], [self.lng floatValue], self.timestamp];
    return desc;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.altitude = [aDecoder decodeObjectForKey:@"altitude"];
    self.horizAcc = [aDecoder decodeObjectForKey:@"horizAcc"];
    self.lapLocationID = [aDecoder decodeObjectForKey:@"lapLocationID"];
    self.lat = [aDecoder decodeObjectForKey:@"lat"];
    self.lng = [aDecoder decodeObjectForKey:@"lng"];
    self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.altitude forKey:@"altitude"];
    [aCoder encodeObject:self.horizAcc forKey:@"horizAcc"];
    [aCoder encodeObject:self.lapLocationID forKey:@"lapLocationID"];
    [aCoder encodeObject:self.lat forKey:@"lat"];
    [aCoder encodeObject:self.lng forKey:@"lng"];
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
}

@end

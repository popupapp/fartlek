//
//  RunManager.m
//  Fartlek
//
//  Created by Jason Humphries on 3/25/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "RunManager.h"
#import "Profile+Database.h"
#import "Lap+Database.h"

static RunManager *g_runManager = nil;

@implementation RunManager

- (id)init
{
    if ((self = [super init])) {
    }
    return self;
}

+ (RunManager *)sharedManager
{
    if (!g_runManager) {
        g_runManager = [[self alloc] init];
    }
    return g_runManager;
}

- (void)resetManager
{
    self.currentProfile = nil;
    self.currentLap = nil;
}

@end

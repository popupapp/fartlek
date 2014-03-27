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
#import "DataManager.h"
@import AVFoundation;
@import AudioToolbox;
@import MediaPlayer;

static RunManager *g_runManager = nil;

@interface RunManager ()
@property (strong, nonatomic) NSArray *orderedLapsForProfile;
@property (assign, nonatomic) int currentLapNumber;
@property (assign, nonatomic) int currentLapSecond;
@property (assign, nonatomic) int currentLapsTotal;
@end

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

- (void)startRun
{
    [self.delegate runDidBegin];
    NSArray *lapsForProfile = [self.currentProfile.laps allObjects];
    self.orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];
    
    self.currentLapsTotal = [[self.currentProfile.laps allObjects] count];
    self.currentLapNumber = 0;
    if (self.currentLapsTotal == self.currentLapNumber) {
        [[[UIAlertView alloc] initWithTitle:@"Good Job!" message:@"Workout Finished!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else {
        [self startLapNumber:self.currentLapNumber];
    }
}

- (float)progressOfRun
{
    float secondsInProfile = [self.currentProfile.duration floatValue] * 60.f;
    return self.currentProfileSecondsElapsed/secondsInProfile;
}

- (void)startLapNumber:(int)lapNumber
{
    self.currentLap = (Lap*)self.orderedLapsForProfile[lapNumber];
    [self.delegate lapDidBegin:lapNumber+1];
    
    self.currentLapSecondsTotal = [self.currentLap.lapTime intValue];
    self.currentLapSecond = 0;
    
    self.currentTimer = [NSTimer timerWithTimeInterval:1.0f
                                                target:self
                                              selector:@selector(updateTimer)
                                              userInfo:nil
                                               repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.currentTimer forMode:NSDefaultRunLoopMode];
}

- (void)updateTimer
{
    [self.delegate timerDidFire];
    self.currentProfileSecondsElapsed += 1;
    // runs every second
    if (self.currentLapSecond == 0) {
        
        NSError *activationError = nil;
        BOOL success = [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&activationError];
        if (!success) {
            NSLog(@"AUDIO ACTIVATION ERROR:%@", activationError.localizedDescription);
        }
        
        AVSpeechSynthesizer *av = [AVSpeechSynthesizer new];
        AVSpeechUtterance *synUtt = [[AVSpeechUtterance alloc] initWithString:self.currentLap.lapStartSpeechString];
//        synUtt.pitchMultiplier = 0.75;
        synUtt.rate = 0.4;
//        synUtt.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
        [synUtt setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:[AVSpeechSynthesisVoice currentLanguageCode]]];
        NSLog(@"speak: %@", self.currentLap.lapStartSpeechString);
        if (![UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            NSLog(@"in the background");
        }
        [av speakUtterance:synUtt];
    }
    self.currentLapSecond += 1;
    self.currentLapSecondsTotal -= 1;
    if (self.currentLapSecondsTotal == 0) {
        // start next lap
        self.currentLapNumber += 1;
        [self.currentTimer invalidate];
        [self startLapNumber:self.currentLapNumber];
    }
}

- (void)resetManager
{
    self.currentProfile = nil;
    self.currentLap = nil;
    [self.currentTimer invalidate];
    self.currentTimer = nil;
    self.currentLapSecondsTotal = 0;
    self.currentProfileSecondsElapsed = 0;
}

@end

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
        AVSpeechSynthesizer *av = [AVSpeechSynthesizer new];
        AVSpeechUtterance *synUtt = [[AVSpeechUtterance alloc] initWithString:@"Nice Job. Workout finished."];
        synUtt.rate = 0.4;
        [synUtt setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:[AVSpeechSynthesisVoice currentLanguageCode]]];
        [av speakUtterance:synUtt];
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

- (UIView*)chartViewForProfile
{
    if (!self.currentProfile) {
        NSLog(@"!self.currentProfile");
    }
    UIView *bareChartView = [[UIView alloc] initWithFrame:CGRectMake(0, 324, 320, 155)];
    bareChartView.backgroundColor = [UIColor whiteColor];
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    hView.backgroundColor = [UIColor whiteColor];
    UILabel *headerLabel = [UILabel new];
    headerLabel.text = @"Your Run";
    [headerLabel sizeToFit];
    [headerLabel setFrame:CGRectMake(320.0/2.0 - headerLabel.frame.size.width/2.0, 0, headerLabel.frame.size.width, headerLabel.frame.size.height)];
    [hView addSubview:headerLabel];
    [bareChartView addSubview:hView];
    
    UIView *fView = [[UIView alloc] initWithFrame:CGRectMake(0, 155+10, 320, 20)];
    UILabel *leftLegendLabel = [UILabel new];
    UILabel *rightLegendLabel = [UILabel new];
    leftLegendLabel.text = @"start";
    rightLegendLabel.text = @"end";
    leftLegendLabel.font = [UIFont systemFontOfSize:12.f];
    rightLegendLabel.font = [UIFont systemFontOfSize:12.f];
    [leftLegendLabel sizeToFit];
    [rightLegendLabel sizeToFit];
    [leftLegendLabel setFrame:CGRectMake(5, 0,
                                         leftLegendLabel.frame.size.width, leftLegendLabel.frame.size.height)];
    [rightLegendLabel setFrame:CGRectMake(bareChartView.frame.size.width - rightLegendLabel.frame.size.width, 0,
                                          rightLegendLabel.frame.size.width, rightLegendLabel.frame.size.height)];
    [fView addSubview:leftLegendLabel];
    [fView addSubview:rightLegendLabel];
    fView.backgroundColor = [UIColor lightGrayColor];
    [bareChartView addSubview:fView];
    
    CGFloat totalDurationInMinutes = [self.currentProfile.duration floatValue];
    CGFloat pointsPerMinute = bareChartView.frame.size.width / totalDurationInMinutes;
    CGFloat xPos = 0.f;
    NSArray *lapsForProfile = [self.currentProfile.laps allObjects];
    self.orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];
    CGFloat oldIntensity = 0.f;
    CGFloat previousIntensity = 0.f;
    CGFloat previousDuration = 0.f;
    for (int i=0; i < self.currentProfile.laps.count; i++) {
        Lap *thisLap = (Lap*)self.orderedLapsForProfile[i];
        BOOL intensityDidIncrease = NO;
        BOOL durationDidIncrease = NO;
        CGFloat currentIntensity = [thisLap.lapIntensity floatValue];
        CGFloat currentDuration = [thisLap.lapTime floatValue];
        if (i == 0) {
            // first lap
            intensityDidIncrease = NO;
            durationDidIncrease = NO;
        } else {
            if (currentIntensity > previousIntensity) {
                intensityDidIncrease = YES;
            }
            if (currentDuration > previousDuration) {
                durationDidIncrease = YES;
            }
        }
        oldIntensity = previousIntensity;
        previousIntensity = currentIntensity;
        
        CGFloat barWidth = ([thisLap.lapTime floatValue] / 60.0) * pointsPerMinute;
        CGFloat barHeight = [thisLap.lapIntensity floatValue] * 30.f;
        UIView *lapBarView = [[UIView alloc] initWithFrame:CGRectMake(xPos,
                                                                      bareChartView.frame.size.height - barHeight,
                                                                      barWidth,
                                                                      barHeight + 10.f)];
        xPos += barWidth;
        lapBarView.backgroundColor = [UIColor blueColor];
        [bareChartView addSubview:lapBarView];
        
        if (intensityDidIncrease) {
            UILabel *newIntensityLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos - (previousDuration*2), bareChartView.frame.size.height - (currentIntensity*30) - 29, 48, 24)];
            [newIntensityLabel setFont:[UIFont systemFontOfSize:12.f]];
            [newIntensityLabel setTextColor:[UIColor whiteColor]];
            [newIntensityLabel setBackgroundColor:[UIColor darkGrayColor]];
            newIntensityLabel.layer.cornerRadius = 3;
            newIntensityLabel.layer.masksToBounds = YES;
            newIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)currentIntensity];
            [newIntensityLabel sizeToFit];
        }
        previousDuration = currentDuration;
    }
    
    return bareChartView;
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

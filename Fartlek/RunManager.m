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
#import "FartlekChartView.h"

static RunManager *g_runManager = nil;

@interface RunManager () <AVSpeechSynthesizerDelegate, FartlekChartDelegate>
@property (strong, nonatomic) NSArray *orderedLapsForProfile;
@property (assign, nonatomic) int currentLapNumber;
@property (assign, nonatomic) int currentLapSecond;
@property (assign, nonatomic) int currentLapsTotal;
@end

@implementation RunManager

- (id)init
{
    if ((self = [super init])) {
        self.isPaused = NO;
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
    [Flurry logEvent:@"START_RUN"];
    [self.delegate runDidBegin];
    NSArray *lapsForProfile = [self.currentProfile.laps allObjects];
    self.orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];
    
    self.currentLapsTotal = (int)[[self.currentProfile.laps allObjects] count];
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

- (int)secondsLeftInRun
{
    int secondsInProfile = [self.currentProfile.duration intValue] * 60;
    return secondsInProfile - self.currentProfileSecondsElapsed;
}

- (int)secondsLeftInLap
{
//    int secondsInLap = [self.currentLap.lapTime intValue] * 60;
    return self.currentLapSecondsTotal - self.currentLapSecond;
}

- (void)startLapNumber:(int)lapNumber
{
    if (self.isPaused) {
        [Flurry logEvent:@"START_LAP_RESUME"];
        // run is resuming from a paused state
//        int secondsPassedBeforePausing = self.currentProfileSecondsElapsed;
        self.currentTimer = [NSTimer timerWithTimeInterval:1.0f
                                                    target:self
                                                  selector:@selector(updateTimer)
                                                  userInfo:nil
                                                   repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.currentTimer forMode:NSDefaultRunLoopMode];
    } else {
        [Flurry logEvent:@"START_LAP_NEW"];
        // normal start lap route
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
}

- (void)updateTimer
{
    [self.delegate timerDidFire];
    self.currentProfileSecondsElapsed += 1;
    // runs every second
    if (self.currentLapSecond == 0) {
        
        NSError *activationError = nil;
        BOOL success = [[AVAudioSession sharedInstance] setActive:YES
                                                      withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                                            error:&activationError];
        if (!success) {
            NSLog(@"AUDIO ACTIVATION ERROR:%@", activationError.localizedDescription);
        }
        
        AVSpeechSynthesizer *av = [AVSpeechSynthesizer new];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.currentLap.lapStartSpeechString];
//        utterance.pitchMultiplier = 0.75;
        utterance.rate = 0.3;
        av.delegate = self;
//        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-IE"]; // en-AU
        [utterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:[AVSpeechSynthesisVoice currentLanguageCode]]];
        NSLog(@"speak: %@", self.currentLap.lapStartSpeechString);
        if (![UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            NSLog(@"in the background");
        }
        [av speakUtterance:utterance];
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

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:0 error:nil];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
//                                     withOptions:AVAudioSessionCategoryOptionDuckOthers
//                                           error:nil];
//    [[AVAudioSession sharedInstance] setActive:YES withOptions: 0 error:nil];

}

- (void)pauseRun
{
    [Flurry logEvent:@"PAUSE_RUN"];
    if ([self.currentTimer isValid]) {
        self.isPaused = YES;
        [self.currentTimer invalidate];
        [self.delegate runDidPause];
    } else {
        [self startLapNumber:self.currentLapNumber];
        self.isPaused = NO;
        [self.delegate runDidResume];
    }
}

- (FartlekChartView*)chartViewForProfileCanEdit:(BOOL)canEdit
{
    if (!self.currentProfile) {
        NSLog(@"!self.currentProfile");
    }
    FartlekChartView *bareChartView = [[FartlekChartView alloc] initWithFrame:CGRectMake(0, 324, 320, 155)];
    bareChartView.delegate = self;
    bareChartView.backgroundColor = [UIColor whiteColor];
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    hView.backgroundColor = [UIColor whiteColor];
    UILabel *headerLabel = [UILabel new];
    NSString *runTitle = @"Your Run";
    if ([self.currentProfile.profileName length] > 0) {
        runTitle= [NSString stringWithFormat:@"%@", self.currentProfile.profileName];
    }
    headerLabel.text = runTitle;
    [headerLabel sizeToFit];
    [headerLabel setFrame:CGRectMake(320.0/2.0 - headerLabel.frame.size.width/2.0, 0, headerLabel.frame.size.width, headerLabel.frame.size.height)];
    [hView addSubview:headerLabel];
    [bareChartView addSubview:hView];
    
    UIView *fView = [[UIView alloc] initWithFrame:CGRectMake(0, 155+10, 320, 20)];
    bareChartView.progressView = nil;
    bareChartView.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    bareChartView.progressView.backgroundColor = [UIColor greenColor];
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
    [fView addSubview:bareChartView.progressView];
    fView.backgroundColor = [UIColor lightGrayColor];
    [bareChartView addSubview:fView];
    
    CGFloat totalDurationInMinutes = [self.currentProfile.duration floatValue];
    NSLog(@"totalDurationInMinutes:%f", totalDurationInMinutes);
    CGFloat pointsPerMinute = bareChartView.frame.size.width / totalDurationInMinutes;
    NSLog(@"pointsPerMinute:%f", pointsPerMinute);
    CGFloat xPos = 0.f;
    NSArray *lapsForProfile = [self.currentProfile.laps allObjects];
    self.orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];
    NSLog(@"number of laps: %d", [lapsForProfile count]);
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
        NSLog(@"%d->lapNumber:%d, barWidth:%f, intensity:%d, duration:%d", i, [thisLap.lapNumber intValue], barWidth, [thisLap.lapIntensity intValue], [thisLap.lapTime intValue]);
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
    
    if (canEdit) {
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [leftButton setTitle:@"<" forState:UIControlStateNormal];
        [leftButton addTarget:bareChartView action:@selector(userChangedProfileLeft) forControlEvents:UIControlEventTouchUpInside];
        [leftButton sizeToFit];
        [leftButton setFrame:CGRectMake(5, bareChartView.frame.size.height/2.0, 20, 20)];
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [rightButton setTitle:@">" forState:UIControlStateNormal];
        [rightButton addTarget:bareChartView action:@selector(userChangedProfileRight) forControlEvents:UIControlEventTouchUpInside];
        [rightButton sizeToFit];
        [rightButton setFrame:CGRectMake(320-rightButton.frame.size.width, bareChartView.frame.size.height/2.0, 20, 20)];
        
        UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:bareChartView action:@selector(userChangedProfileRight)];
        [leftGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:bareChartView action:@selector(userChangedProfileLeft)];
        [rightGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [bareChartView addGestureRecognizer:rightGestureRecognizer];
        [bareChartView addGestureRecognizer:leftGestureRecognizer];

        [bareChartView addSubview:leftButton];
        [bareChartView addSubview:rightButton];
    }
    
    return bareChartView;
}

#pragma mark - DYNAMIC PROPERTIES

- (NSNumber *)userPaceMinutes
{
    if (![self persistedValueForKey:USER_PACE_MINUTES_KEY]) {
        return @0;
    } else {
        return [self persistedValueForKey:USER_PACE_MINUTES_KEY];
    }
}

- (void)setUserPaceMinutes:(NSNumber *)userPaceMinutes
{
    [self persistValue:userPaceMinutes forKey:USER_PACE_MINUTES_KEY];
}

- (NSNumber *)userPaceSeconds
{
    if (![self persistedValueForKey:USER_PACE_SECONDS_KEY]) {
        return @0;
    } else {
        return [self persistedValueForKey:USER_PACE_SECONDS_KEY];
    }
}

- (void)setUserPaceSeconds:(NSNumber *)userPaceSeconds
{
    [self persistValue:userPaceSeconds forKey:USER_PACE_SECONDS_KEY];
}

#pragma mark - CONVENIENCE METHODS FOR NSUSERDEFAULTS AND NSNOTIFICATIONCENTER

- (id)persistedValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)persistValue:(id)value forKey:(NSString *)key
{
    if (value) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)notifyObservers:(NSString *)notificationName userInfo:(NSDictionary *)notificationUserInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:notificationUserInfo];
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

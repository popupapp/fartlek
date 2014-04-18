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
#import "Run+Database.h"
//#import "LapLocation+Database.h"
#import "DataManager.h"
@import AVFoundation;
@import AudioToolbox;
@import MediaPlayer;
#import "FartlekChartView.h"
#import "LocationManager.h"
#import "RunLocation.h"

static RunManager *g_runManager = nil;

@interface RunManager () <AVSpeechSynthesizerDelegate, FartlekChartDelegate>
@property (strong, nonatomic) NSArray *orderedLapsForProfile;
@property (assign, nonatomic) int currentLapNumber;
@property (assign, nonatomic) int currentLapElapsedSeconds;
@property (assign, nonatomic) int currentLapsTotal;
@property (assign, nonatomic) int totalNumberOfLocationsAdded;
@end

@implementation RunManager

- (id)init
{
    if ((self = [super init])) {
        self.isPaused = NO;
        self.runLocations = [NSMutableArray array];
        self.runLocationsForDistanceCalculations = [NSMutableArray array];
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

#pragma mark - START RUN

- (void)startRun
{
    [[LocationManager sharedManager] restartStandardLocationCheckAndResetLocationCount:YES];
    [Flurry logEvent:@"START_RUN"];
    self.totalNumberOfLocationsAdded = 0;
    // CREATE currentRun OBJECT
    self.currentRun = [[DataManager sharedManager] createRun];
    self.currentRun.profile = self.currentProfile;
    [self.delegate runDidBegin];
    NSArray *lapsForProfile = [self.currentProfile.laps allObjects];
    self.orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];
    
    self.currentLapsTotal = (int)[[self.currentProfile.laps allObjects] count];
    self.currentLapNumber = 0;
    self.currentLapDistanceTotal = 0;
    self.currentRunDistanceTotal = 0;
    [self.currentRun saveSuccess:^{
        NSLog(@"SUCCESSFULLY SAVED RUN(1): %@", self.currentRun);
        [self startLapNumber:self.currentLapNumber];
    } failure:^(NSError *error) {
        NSLog(@"FAILED RUN SAVE(1): %@", error);
        [[[UIAlertView alloc] initWithTitle:@"FAIL" message:nil delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
    }];
}

#pragma mark - PAUSE RUN

- (void)pauseRun
{
    [Flurry logEvent:@"PAUSE_RUN"];
    if ([self.currentTimer isValid]) {
        self.isPaused = YES;
        [self.currentTimer invalidate];
        [self.delegate runDidPause];
        [[LocationManager sharedManager] stopLocationUpdates];
    } else {
        [self startLapNumber:self.currentLapNumber];
        self.isPaused = NO;
        [self.delegate runDidResume];
        [[LocationManager sharedManager] restartStandardLocationCheckAndResetLocationCount:NO];
    }
}

#pragma mark - SAVE AND STOP RUN

- (void)saveRun
{
    [self.delegate runDidSave];
}

- (void)stopRun
{
    [self.delegate runDidStop];
    NSLog(@"runDistance: %@", @(self.currentRunDistanceTotal));
    self.currentRun.runDistance = @(self.currentRunDistanceTotal);
    float runPace = (self.currentRunSecondsElapsed / 60.f) / (self.currentRunDistanceTotal / METERS_PER_MILE);
    NSLog(@"runPace: %.4f", runPace);
    self.currentRun.runPace = @(runPace);
    [self.currentRun saveSuccess:^{
        NSLog(@"SUCCESSFULLY SAVED RUN2: %@", self.currentRun);
        [self resetManager];
    } failure:^(NSError *error) {
        NSLog(@"FAILED RUN SAVE2: %@", error);
        [self resetManager];
    }];
}

- (void)deleteRun
{
    [self.currentRun deleteSuccess:^{
        NSLog(@"SUCCESSFUL RUN DELETE");
        [self resetManager];
    } failure:^(NSError *error) {
        NSLog(@"FAILED RUN DELETE: %@", error);
        [self resetManager];
    }];
}

#pragma mark - START A NEW LAP

- (void)startLapNumber:(int)lapNumber
{
    NSLog(@"startLapNumber:%d, orderedLapsForProfile:%lu", lapNumber, (unsigned long)self.orderedLapsForProfile.count);
    if (self.isPaused) {
        [Flurry logEvent:@"START_LAP_RESUME"];
        // run is resuming from a paused state
        self.currentTimer = [NSTimer timerWithTimeInterval:1.0f
                                                    target:self
                                                  selector:@selector(updateTimer)
                                                  userInfo:nil
                                                   repeats:YES];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.currentTimer forMode:NSDefaultRunLoopMode];
    } else {
        [Flurry logEvent:@"START_LAP_NEW"];
//        // if not the first lap, save the lap pace and distance to the previous lap
//        if (self.currentLap) {
//            self.currentLap.lapDistance = @(self.currentLapDistanceTotal);
//            float lapPace = (self.currentLapElapsedSeconds / 60.f) / (self.currentLapDistanceTotal / METERS_PER_MILE);
//            self.currentLap.lapPace = @(lapPace);
//        }
        // the idea is to clear out self.runLocations at the beginning of each lap
        // at the start of each lap after the 1st, self.runLocations contains all the locations for the preceding laps, so they need to be cleared out
        [self.runLocations removeAllObjects];
        // normal start lap route
        self.currentLap = (Lap*)self.orderedLapsForProfile[lapNumber];
        // CREATE LAP AND ASSIGN TO CURRENT RUN
        self.currentLap.lapRun = self.currentRun;
//        [self.currentRun addLapsObject:self.currentLap];
        [self.delegate lapDidBegin:lapNumber+1];
        self.currentLapSecondsTotal = [self.currentLap.lapTime intValue];
        self.currentLapElapsedSeconds = 0;
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
    self.currentRunSecondsElapsed += 1;
    // runs every second
    if (self.currentLapElapsedSeconds == 0) {
        self.currentLapDistanceTotal = 0;
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
    self.currentLapElapsedSeconds += 1;
    self.currentLap.lapElapsedSeconds = @(self.currentLapElapsedSeconds);
    self.currentLapSecondsTotal -= 1;
    if (self.currentLapSecondsTotal == 0) {
        // start next lap
        self.currentLapNumber += 1;
        [self.currentTimer invalidate];
        if (self.currentLapNumber < self.orderedLapsForProfile.count) {
//            if (self.currentLapsTotal == self.currentLapNumber) {
                [self startLapNumber:self.currentLapNumber];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Good Job!" message:@"Workout Finished!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            NSError *activationError = nil;
            BOOL success = [[AVAudioSession sharedInstance] setActive:YES
                                                          withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                                                error:&activationError];
            if (!success) {
                NSLog(@"AUDIO ACTIVATION ERROR:%@", activationError.localizedDescription);
            }
            AVSpeechSynthesizer *av = [AVSpeechSynthesizer new];
            AVSpeechUtterance *synUtt = [[AVSpeechUtterance alloc] initWithString:@"Nice Job. Workout finished."];
            synUtt.rate = 0.3;
            av.delegate = self;
            [synUtt setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:[AVSpeechSynthesisVoice currentLanguageCode]]];
            [av speakUtterance:synUtt];
            [self stopRun];
        }
    }
}

#pragma mark - ADD LOCATION TO RUN

- (void)addLocationToRun:(CLLocation*)location
{
    NSLog(@"currentRunDistanceTotal:%f", self.currentRunDistanceTotal);
    self.totalNumberOfLocationsAdded += 1;
    NSLog(@"totalNumberOfLocationsAdded:%d", self.totalNumberOfLocationsAdded);
    CLLocation *lastLoc = [self.runLocationsForDistanceCalculations lastObject];
    if (!lastLoc) {
        NSLog(@".. in the lastLoc guard block");
        lastLoc = location;
    }
    
    CLLocation *thisLoc = location;
    double distanceFromLastLocation = [thisLoc distanceFromLocation:lastLoc];
    if (distanceFromLastLocation > 0) {
        self.currentRunDistanceTotal += (float)distanceFromLastLocation;
        self.currentLapDistanceTotal += (float)distanceFromLastLocation;
    }
    NSLog(@"distanceFromLastLocation:%f", (float)distanceFromLastLocation);
    [self.runLocationsForDistanceCalculations addObject:location];
//    if (self.currentLap && (self.totalNumberOfLocationsAdded % 10 == 0 || self.totalNumberOfLocationsAdded == 1)) {
    if (self.currentLap) {
        NSLog(@".. self.currentLap is not nil");
        self.currentLap.lapDistance = @(self.currentLapDistanceTotal);
//        LapLocation *lapLoc = [[DataManager sharedManager] createLapLocation];
        RunLocation *runLoc = [RunLocation new];
        runLoc.lat = @(location.coordinate.latitude);
        runLoc.lng = @(location.coordinate.longitude);
        runLoc.horizAcc = @(location.horizontalAccuracy);
        runLoc.timestamp = location.timestamp;
        runLoc.altitude = @(location.altitude);
#pragma warning !! self.runLocations needs to be cleared out at the end of each lap
        [self.runLocations addObject:runLoc];
        NSData *locationsArrayData = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:[self.runLocations copy]]];
//        self.currentLap.locationsArray = nil;
        self.currentLap.locationsArray = locationsArrayData;
    } else {
        NSLog(@"!! self.currentLap IS NIL");
    }
}

#pragma mark - SPEECH SYNTHESIZER DELEGATE METHODS

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:0 error:nil];
}

#pragma mark - CHART VIEW GENERATION

- (FartlekChartView*)chartViewForProfileCanEdit:(BOOL)canEdit
{
    if (!self.currentProfile) {
        NSLog(@"!self.currentProfile");
    }
    FartlekChartView *bareChartView = [[FartlekChartView alloc] initWithFrame:CGRectMake(56, 150, 210, 284)];
    bareChartView.delegate = self;
    bareChartView.backgroundColor = [UIColor clearColor];
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bareChartView.frame.size.width, 20)];
    hView.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [UILabel new];
    NSString *runTitle = @"Your Run";
    if ([self.currentProfile.profileName length] > 0) {
        runTitle = [NSString stringWithFormat:@"%@", self.currentProfile.profileName];
    }
    headerLabel.text = runTitle;
    [headerLabel sizeToFit];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setFrame:CGRectMake(bareChartView.frame.size.width/2.0 - headerLabel.frame.size.width/2.0, 0, headerLabel.frame.size.width, headerLabel.frame.size.height)];
    [hView addSubview:headerLabel];
    [bareChartView addSubview:hView];
        
    CGFloat totalDurationInMinutes = [self.currentProfile.duration floatValue];
    NSLog(@"totalDurationInMinutes:%f", totalDurationInMinutes);
    CGFloat pointsPerMinute = bareChartView.frame.size.width / totalDurationInMinutes;
    NSLog(@"pointsPerMinute:%f", pointsPerMinute);
    CGFloat xPos = 0.f;
    NSArray *lapsForProfile = [self.currentProfile.laps allObjects];
    self.orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];
    NSLog(@"number of laps: %d", [lapsForProfile count]);
//    CGFloat oldIntensity = 0.f;
//    CGFloat previousIntensity = 0.f;
    CGFloat previousDuration = 0.f;
    for (int i=0; i < self.currentProfile.laps.count; i++) {
        Lap *thisLap = (Lap*)self.orderedLapsForProfile[i];
        BOOL intensityDidIncrease = NO;
//        BOOL durationDidIncrease = NO;
        CGFloat currentIntensity = [thisLap.lapIntensity floatValue];
        CGFloat currentDuration = [thisLap.lapTime floatValue];
//        if (i == 0) {
            // first lap
//            intensityDidIncrease = NO;
//            durationDidIncrease = NO;
//        } else {
//            if (currentIntensity > previousIntensity) {
//                intensityDidIncrease = YES;
//            }
//            if (currentDuration > previousDuration) {
//                durationDidIncrease = YES;
//            }
//        }
//        oldIntensity = previousIntensity;
//        previousIntensity = currentIntensity;
        
        CGFloat barWidth = ([thisLap.lapTime floatValue] / 60.0) * pointsPerMinute;
        NSLog(@"%d->lapNumber:%d, barWidth:%f, intensity:%d, duration:%d", i, [thisLap.lapNumber intValue], barWidth, [thisLap.lapIntensity intValue], [thisLap.lapTime intValue]);
        CGFloat barHeight = [thisLap.lapIntensity floatValue] * 20.f;
        UIView *lapBarView = [[UIView alloc] initWithFrame:CGRectMake(xPos,
                                                                      bareChartView.frame.size.height - barHeight - 110.0,
                                                                      barWidth,
                                                                      barHeight + 20.f)];
        xPos += barWidth;
        lapBarView.backgroundColor = [UIColor whiteColor];
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

#pragma mark - RUN STATS

- (float)currentPaceOfRun
{
    // run pace = # minutes elapsed in run / # miles traveled this run
    float runPace = (self.currentRunSecondsElapsed / 60.f) / (self.currentRunDistanceTotal / METERS_PER_MILE);
    return runPace;
}

- (float)currentPaceOfLap
{
    // lap pace = # minutes elapsed in lap / # miles traveled this lap
    float lapPace = (self.currentLapElapsedSeconds / 60.f) / (self.currentLapDistanceTotal / METERS_PER_MILE);
    self.currentLap.lapPace = @(lapPace);
    return lapPace;
}

- (float)progressOfRun
{
    float secondsInProfile = [self.currentProfile.duration floatValue] * 60.f;
    return self.currentRunSecondsElapsed/secondsInProfile;
}

- (int)secondsLeftInRun
{
    int secondsInProfile = [self.currentProfile.duration intValue] * 60;
    return secondsInProfile - self.currentRunSecondsElapsed;
}

- (int)secondsLeftInLap
{
    return self.currentLapSecondsTotal - self.currentLapElapsedSeconds;
}

- (int)secondsElapsedInLap
{
    return self.currentLapElapsedSeconds;
}

- (int)secondsElapsedInRun
{
    return self.currentRunSecondsElapsed;
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

#pragma mark - RESET MANAGER DATA

- (void)resetManager
{
//    self.currentRun = nil;
    self.currentProfile = nil;
    self.currentLap = nil;
    [self.currentTimer invalidate];
    self.currentTimer = nil;
    self.currentLapSecondsTotal = 0;
    self.currentRunSecondsElapsed= 0;
    self.currentLapDistanceTotal = 0;
    self.currentRunDistanceTotal = 0;
    [self.runLocations removeAllObjects];
    [self.runLocationsForDistanceCalculations removeAllObjects];
    [[LocationManager sharedManager] stopLocationUpdates];
}

@end

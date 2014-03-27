//
//  CurrentWorkoutViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/25/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "CurrentWorkoutViewController.h"
#import "WorkoutSummaryViewController.h"
#import "RunManager.h"
#import "Run+Database.h"
#import "Profile+Database.h"
#import "Lap+Database.h"
@import AVFoundation;
@import AudioToolbox;
@import MediaPlayer;

@interface CurrentWorkoutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentLapLabel;
@property (weak, nonatomic) IBOutlet UILabel *timetoNextLapLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentIntensityLabel;
@property (strong, nonatomic) NSArray *orderedLapsForProfile;
@property (strong, nonatomic) NSTimer *currentTimer;
@property (strong, nonatomic) Lap *currentLap;
@property (assign, nonatomic) int currentLapSecondsTotal;
@property (assign, nonatomic) int currentLapSecond;
@property (assign, nonatomic) int currentLapNumber;
@property (assign, nonatomic) int currentLapsTotal;
@end

@implementation CurrentWorkoutViewController

- (void)awakeFromNib
{
    NSLog(@"checking RunManager");
    NSLog(@"runManager:%@", [[RunManager sharedManager] currentProfile]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = FARTLEK_YELLOW;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.barTintColor = FARTLEK_YELLOW;
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Gotham-Book" size:20.0], NSFontAttributeName, nil];
    
    [self registerForAudioNotifications];
    
    // start run
    if ([[RunManager sharedManager] currentProfile]) {
        [self startRun];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Current Run Profile Set" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void)registerForAudioNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupted:)
                                                 name:@"AVAudioSessionInterruptionNotification" object:nil];
}

- (void)audioSessionInterrupted:(NSNotification*)notif
{
    NSLog(@"audioSessionInterrupted. notif userInfo: %@", notif.userInfo);
}

- (void)startRun
{
    // setup Audio Session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&setCategoryError];
    if (!success) {
        NSLog(@"CATEGORY AUDIO ERROR:%@", setCategoryError.localizedDescription);
    }
    
    Profile *runProfile = [[RunManager sharedManager] currentProfile];
    NSArray *lapsForProfile = [runProfile.laps allObjects];
    self.orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];

    self.currentLapsTotal = [[runProfile.laps allObjects] count];
    self.currentLapNumber = 0;
    [self startLapNumber:self.currentLapNumber];
}

- (void)startLapNumber:(int)lapNumber
{
    self.currentLap = (Lap*)self.orderedLapsForProfile[lapNumber];
    self.currentLapLabel.text = [NSString stringWithFormat:@"%d/%d", [self.currentLap.lapNumber intValue], self.currentLapsTotal];
    self.currentIntensityLabel.text = [NSString stringWithFormat:@"%d", [self.currentLap.lapIntensity intValue]];
    
    self.currentLapSecondsTotal = [self.currentLap.lapTime intValue] * 60;
    self.currentLapSecond = 0;
    
//    UILocalNotification *timerNotif = [[UILocalNotification alloc] init];
//    timerNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.currentLapSecondsTotal];
//    timerNotif.timeZone = [NSTimeZone defaultTimeZone];
//    timerNotif.repeatInterval = 0;
//    [[UIApplication sharedApplication] scheduleLocalNotification:timerNotif];
//    NSLog(@"scheduled a local notif for %d seconds out", self.currentLapSecondsTotal);
    
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
//            NSLog(@"Background time remaining = %.1f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
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
    } else {
        int timeLeftInLap = self.currentLapSecondsTotal;
        int minutesLeftInLap = timeLeftInLap / 60;
        int secondsLeftInLap = timeLeftInLap % 60;
        self.timetoNextLapLabel.text = [NSString stringWithFormat:@"%d:%.2d", minutesLeftInLap, secondsLeftInLap];
    }
}

- (IBAction)pauseRunAction:(id)sender
{
    //
}

- (void)killTimer
{
    [self.currentTimer invalidate];
}


- (NSString *)OSStatusToStr:(OSStatus)st
{
    switch (st) {
        case kAudioFileUnspecifiedError:
            return @"kAudioFileUnspecifiedError";
            
        case kAudioFileUnsupportedFileTypeError:
            return @"kAudioFileUnsupportedFileTypeError";
            
        case kAudioFileUnsupportedDataFormatError:
            return @"kAudioFileUnsupportedDataFormatError";
            
        case kAudioFileUnsupportedPropertyError:
            return @"kAudioFileUnsupportedPropertyError";
            
        case kAudioFileBadPropertySizeError:
            return @"kAudioFileBadPropertySizeError";
            
        case kAudioFilePermissionsError:
            return @"kAudioFilePermissionsError";
            
        case kAudioFileNotOptimizedError:
            return @"kAudioFileNotOptimizedError";
            
        case kAudioFileInvalidChunkError:
            return @"kAudioFileInvalidChunkError";
            
        case kAudioFileDoesNotAllow64BitDataSizeError:
            return @"kAudioFileDoesNotAllow64BitDataSizeError";
            
        case kAudioFileInvalidPacketOffsetError:
            return @"kAudioFileInvalidPacketOffsetError";
            
        case kAudioFileInvalidFileError:
            return @"kAudioFileInvalidFileError";
            
        case kAudioFileOperationNotSupportedError:
            return @"kAudioFileOperationNotSupportedError";
            
        case kAudioFileNotOpenError:
            return @"kAudioFileNotOpenError";
            
        case kAudioFileEndOfFileError:
            return @"kAudioFileEndOfFileError";
            
        case kAudioFilePositionError:
            return @"kAudioFilePositionError";
            
        case kAudioFileFileNotFoundError:
            return @"kAudioFileFileNotFoundError";
            
        default:
            return @"unknown error";
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

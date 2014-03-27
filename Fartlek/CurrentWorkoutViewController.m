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

@interface CurrentWorkoutViewController () <RunManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *currentLapLabel;
@property (weak, nonatomic) IBOutlet UILabel *timetoNextLapLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentIntensityLabel;
@end

@implementation CurrentWorkoutViewController

- (void)awakeFromNib
{
    NSLog(@"runManager currentProfile:%@", [[RunManager sharedManager] currentProfile]);
    [RunManager sharedManager].delegate = self;
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
    [self setupAudioSession];
    
    // start run
    if ([[RunManager sharedManager] currentProfile]) {
        [[RunManager sharedManager] startRun];
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

- (void)setupAudioSession
{
    // setup Audio Session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&setCategoryError];
    if (!success) {
        NSLog(@"CATEGORY AUDIO ERROR:%@", setCategoryError.localizedDescription);
    }
}

#pragma mark - RunManagerDelegate

- (void)runDidBegin
{
    NSLog(@"runDidBegin");
}

- (void)lapDidBegin:(int)lapNumber
{
    NSLog(@"lapDidBegin:%d",lapNumber);
    Lap *lap = [[RunManager sharedManager] currentLap];
    self.currentLapLabel.text = [NSString stringWithFormat:@"%d/%d", lapNumber, [[[[RunManager sharedManager] currentProfile] laps] count]];
    self.currentIntensityLabel.text = [NSString stringWithFormat:@"%d", [lap.lapIntensity intValue]];
}

- (void)timerDidFire
{
    NSLog(@"timerDidFire");
    int timeLeftInLap = [[RunManager sharedManager] currentLapSecondsTotal];
    int minutesLeftInLap = timeLeftInLap / 60;
    int secondsLeftInLap = timeLeftInLap % 60;
    self.timetoNextLapLabel.text = [NSString stringWithFormat:@"%d:%.2d", minutesLeftInLap, secondsLeftInLap];
}

- (IBAction)pauseRunAction:(id)sender
{
    //
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

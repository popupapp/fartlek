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
#import "FartlekChartView.h"

@interface CurrentWorkoutViewController () <RunManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *currentLapLabel;
@property (weak, nonatomic) IBOutlet UILabel *timetoNextLapLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentIntensityLabel;
@property (strong, nonatomic) FartlekChartView *bareChartView;
//@property (strong, nonatomic) UIView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
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
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.backgroundColor = FARTLEK_YELLOW;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//    self.navigationController.navigationBar.barTintColor = FARTLEK_YELLOW;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Gotham-Book" size:20.0], NSFontAttributeName, nil];
//    self.view.backgroundColor = FARTLEK_YELLOW;
    
    [self registerForAudioNotifications];
    [self setupAudioSession];
    [self setupChart];
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.currentLapLabel.text = [NSString stringWithFormat:@"%d/%lu", lapNumber, (unsigned long)[[[[RunManager sharedManager] currentProfile] laps] count]];
    self.currentIntensityLabel.text = [NSString stringWithFormat:@"%d", [lap.lapIntensity intValue]];
}

- (void)timerDidFire
{
//    NSLog(@"timerDidFire");
    int timeLeftInLap = [[RunManager sharedManager] currentLapSecondsTotal];
    int minutesLeftInLap = timeLeftInLap / 60;
    int secondsLeftInLap = timeLeftInLap % 60;
    self.timetoNextLapLabel.text = [NSString stringWithFormat:@"%d:%.2d", minutesLeftInLap, secondsLeftInLap];
    CGRect pFrame = self.bareChartView.progressView.frame;
    self.bareChartView.progressView.frame = CGRectMake(pFrame.origin.x, pFrame.origin.y,
                                         320.0 * [[RunManager sharedManager] progressOfRun], pFrame.size.height);
//    NSLog(@"progressOfRun:%f", [[RunManager sharedManager] progressOfRun]);
}

- (void)runDidResume
{
    NSLog(@"runDidResume");
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
}

- (void)runDidPause
{
    NSLog(@"runDidPause");
    [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
}

- (IBAction)pauseRunAction:(id)sender
{
    [[RunManager sharedManager] pauseRun];
}


- (void)setupChart
{
    self.bareChartView = [[RunManager sharedManager] chartViewForProfileCanEdit:NO];
    [self.view addSubview:self.bareChartView];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

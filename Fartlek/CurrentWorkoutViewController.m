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

@interface CurrentWorkoutViewController () <RunManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *currentLapLabel;
@property (weak, nonatomic) IBOutlet UILabel *timetoNextLapLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentIntensityLabel;
//@property (strong, nonatomic) FartlekChartView *bareChartView;
//@property (strong, nonatomic) UIView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UILabel *lapHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *intensityHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeToNextLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLapHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapPaceHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapPaceValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTimeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapDistanceHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapDistanceValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingLapTimeHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDistanceHardLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDistanceValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

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
    
    UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    imgButton.frame = CGRectMake(0.0, 0.0, 35.f, 31.f);
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithCustomView:imgButton];
    [imgButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = b;
    
    UIFont *joseFontBoldItalic22 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:22.f];
    UIFont *joseFontBoldItalic24 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:24.f];
    [self.lapHardLabel setFont:joseFontBoldItalic22];
    [self.intensityHardLabel setFont:joseFontBoldItalic22];
    [self.timeToNextLabel setFont:joseFontBoldItalic22];
    [self.pauseButton.titleLabel setFont:joseFontBoldItalic22];
    [self.stopButton.titleLabel setFont:joseFontBoldItalic22];
    [self.currentLapLabel setFont:joseFontBoldItalic22];
    [self.currentIntensityLabel setFont:joseFontBoldItalic22];
    [self.currentLapHardLabel setFont:joseFontBoldItalic24];
    
    [self.lapPaceHardLabel setFont:joseFontBoldItalic22];
    [self.lapPaceValueLabel setFont:joseFontBoldItalic22];
    [self.elapsedTimeHardLabel setFont:joseFontBoldItalic22];
    [self.elapsedTimeValueLabel setFont:joseFontBoldItalic22];
    [self.lapDistanceHardLabel setFont:joseFontBoldItalic22];
    [self.lapDistanceValueLabel setFont:joseFontBoldItalic22];
    [self.remainingLapTimeHardLabel setFont:joseFontBoldItalic22];
    [self.totalHardLabel setFont:joseFontBoldItalic24];
    [self.totalTimeHardLabel setFont:joseFontBoldItalic22];
    [self.totalTimeValueLabel setFont:joseFontBoldItalic22];
    [self.totalDistanceHardLabel setFont:joseFontBoldItalic22];
    [self.totalDistanceValueLabel setFont:joseFontBoldItalic22];
    
    [self registerForAudioNotifications];
    [self setupAudioSession];
    
    // start run
    if ([[RunManager sharedManager] currentProfile]) {
        [[RunManager sharedManager] startRun];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Current Run Profile Set" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void)goBackNow
{
    [self.navigationController popViewControllerAnimated:YES];
    [[RunManager sharedManager] resetManager];
    [[RunManager sharedManager] setCurrentRun:nil];
}

-(void)backAction
{
    if ([self.stopButton.titleLabel.text isEqualToString:@"Stop"]) {
        UIAlertView *goBackConfirmAlert = [UIAlertView new];
        goBackConfirmAlert.title = @"Are you sure you want to stop this run?";
        goBackConfirmAlert.message = nil;
        goBackConfirmAlert.delegate = self;
        goBackConfirmAlert.tag = 1;
        [goBackConfirmAlert addButtonWithTitle:@"Yes"];
        [goBackConfirmAlert addButtonWithTitle:@"No"];
        [goBackConfirmAlert show];
    } else {
        UIAlertView *dontSaveConfirmAlert = [UIAlertView new];
        dontSaveConfirmAlert.title = @"Save this run?";
        dontSaveConfirmAlert.message = nil;
        dontSaveConfirmAlert.delegate = self;
        dontSaveConfirmAlert.tag = 3;
        [dontSaveConfirmAlert addButtonWithTitle:@"Save"];
        [dontSaveConfirmAlert addButtonWithTitle:@"Discard"];
        [dontSaveConfirmAlert show];
    }
}

- (IBAction)stopOrSaveRunAction:(id)sender
{
    if ([self.stopButton.titleLabel.text isEqualToString:@"Stop"]) {
        UIAlertView *stopRunConfirmAlert = [UIAlertView new];
        stopRunConfirmAlert.title = @"Are you sure you want to stop this run?";
        stopRunConfirmAlert.message = nil;
        stopRunConfirmAlert.delegate = self;
        stopRunConfirmAlert.tag = 2;
        [stopRunConfirmAlert addButtonWithTitle:@"Yes"];
        [stopRunConfirmAlert addButtonWithTitle:@"No"];
        [stopRunConfirmAlert show];
    } else if ([self.stopButton.titleLabel.text isEqualToString:@"Save"]) {
        // save run
        [[RunManager sharedManager] saveRun];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        // back
        if (buttonIndex == 0) {
            [[RunManager sharedManager] stopRun];
            [[RunManager sharedManager] deleteRun];
            [self goBackNow];
        }
    } else if (alertView.tag == 2) {
        // stop
        if (buttonIndex == 0) {
            [[RunManager sharedManager] stopRun];
        }
    } else if (alertView.tag == 3) {
        // back after stopped
        if (buttonIndex == 0) {
            // save
            [self goBackNow];
        } else {
            // delete
            [[RunManager sharedManager] deleteRun];
            [self goBackNow];
        }
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
    self.pauseButton.enabled = YES;
    self.stopButton.enabled = YES;
}

- (void)lapDidBegin:(int)lapNumber
{
    NSLog(@"lapDidBegin:%d",lapNumber);
    Lap *lap = [[RunManager sharedManager] currentLap];
    self.currentLapLabel.text = [NSString stringWithFormat:@"%d/%lu", lapNumber, (unsigned long)[[[[RunManager sharedManager] currentProfile] laps] count]];
    int ordinalNumber = [lap.lapIntensity intValue];
    NSString *ordinalString = [self getOrdinalSuffix:ordinalNumber];
    if (ordinalNumber == 0) {
        self.currentIntensityLabel.text = @"Slow Pace";
    } else {
        self.currentIntensityLabel.text = [NSString stringWithFormat:@"%@ Gear!", ordinalString];
    }
}

- (void)runDidStop
{
    self.pauseButton.enabled = NO;
    [self.stopButton setTitle:@"Save" forState:UIControlStateNormal];
}

- (void)runDidSave
{
    [[[UIAlertView alloc] initWithTitle:@"Run Saved" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    [self goBackNow];
}

- (void)runDidNotSave
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Run did not save." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (NSString*)getOrdinalSuffix:(int)number
{
	NSArray *suffixLookup = [NSArray arrayWithObjects:@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th", nil];
	if (number % 100 >= 11 && number % 100 <= 13) {
		return [NSString stringWithFormat:@"%d%@", number, @"th"];
	}
	return [NSString stringWithFormat:@"%d%@", number, [suffixLookup objectAtIndex:(number % 10)]];
}

- (void)timerDidFire
{
//    NSLog(@"timerDidFire");
//    Lap *currentLap = [[RunManager sharedManager] currentLap];
    int timeLeftInLap = [[RunManager sharedManager] currentLapSecondsTotal];
//    int lapDistance = [currentLap.lapTime intValue] * 60;
//    int secondsLeftInRun = [[RunManager sharedManager] secondsLeftInRun];
    
    int totalSecondsElapsedInRun = [[RunManager sharedManager] secondsElapsedInRun];
    int minutesElapsedInRun = totalSecondsElapsedInRun / 60;
    int secondsElapsedInRun = totalSecondsElapsedInRun % 60;
    
    int totalSecondsElapsedInLap = [[RunManager sharedManager] secondsElapsedInLap];
    int minutesElapsedInLap = totalSecondsElapsedInLap / 60.f;
    int secondsElapsedInLap =  totalSecondsElapsedInLap % 60;
    
    int minutesLeftInLap = timeLeftInLap / 60;
    int secondsLeftInLap = timeLeftInLap % 60;
    self.timetoNextLapLabel.text = [NSString stringWithFormat:@"%d:%.2d", minutesLeftInLap, secondsLeftInLap];
    UIFont *joseFontBoldItalic22 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:22.f];
    [self.timetoNextLapLabel setFont:joseFontBoldItalic22];
    self.elapsedTimeValueLabel.text = [NSString stringWithFormat:@"%d:%.2d", minutesElapsedInLap, secondsElapsedInLap];
    self.totalTimeValueLabel.text = [NSString stringWithFormat:@"%d:%.2d", minutesElapsedInRun, secondsElapsedInRun];
//    self.totalDistanceValueLabel.text = @"";
    self.lapDistanceValueLabel.text = [NSString stringWithFormat:@"%.2f mi", [[RunManager sharedManager] currentLapDistanceTotal]];
    self.lapPaceValueLabel.text = [NSString stringWithFormat:@"%.2f min/mi", [[RunManager sharedManager] currentPaceOfLap]];
    self.totalDistanceValueLabel.text = [NSString stringWithFormat:@"%.4f mi", [[RunManager sharedManager] currentRunDistanceTotal]];
    
//    CGRect pFrame = self.bareChartView.progressView.frame;
//    self.bareChartView.progressView.frame = CGRectMake(pFrame.origin.x, pFrame.origin.y,
//                                         320.0 * [[RunManager sharedManager] progressOfRun], pFrame.size.height);
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


//- (void)setupChart
//{
//    self.bareChartView = [[RunManager sharedManager] chartViewForProfileCanEdit:NO];
//    [self.view addSubview:self.bareChartView];
//}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

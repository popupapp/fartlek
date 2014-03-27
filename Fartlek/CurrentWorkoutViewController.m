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
@property (strong, nonatomic) UIView *bareChartView;
@property (strong, nonatomic) UIView *progressView;
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
//    NSLog(@"timerDidFire");
    int timeLeftInLap = [[RunManager sharedManager] currentLapSecondsTotal];
    int minutesLeftInLap = timeLeftInLap / 60;
    int secondsLeftInLap = timeLeftInLap % 60;
    self.timetoNextLapLabel.text = [NSString stringWithFormat:@"%d:%.2d", minutesLeftInLap, secondsLeftInLap];
    CGRect pFrame = self.progressView.frame;
    self.progressView.frame = CGRectMake(pFrame.origin.x, pFrame.origin.y,
                                         320.0 * [[RunManager sharedManager] progressOfRun], pFrame.size.height);
//    NSLog(@"progressOfRun:%f", [[RunManager sharedManager] progressOfRun]);
}

- (IBAction)pauseRunAction:(id)sender
{
    //
}


- (void)setupChart
{
    Profile *profile = [[RunManager sharedManager] currentProfile];
    if (!profile) {
        NSLog(@"![[RunManager sharedManager] currentProfile]");
    }
    if (!self.bareChartView) {
        self.bareChartView = [[UIView alloc] initWithFrame:CGRectMake(0, 270, 320, 155)];
    }
    self.bareChartView.backgroundColor = [UIColor whiteColor];
    
    UIView *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    hView.backgroundColor = [UIColor whiteColor];
    UILabel *headerLabel = [UILabel new];
    headerLabel.text = @"Your Run";
    [headerLabel sizeToFit];
    [headerLabel setFrame:CGRectMake(320.0/2.0 - headerLabel.frame.size.width/2.0, 0, headerLabel.frame.size.width, headerLabel.frame.size.height)];
    [hView addSubview:headerLabel];
    [self.bareChartView addSubview:hView];
    
    UIView *fView = [[UIView alloc] initWithFrame:CGRectMake(0, 155+10, 320, 20)];
    self.progressView = nil;
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    self.progressView.backgroundColor = [UIColor greenColor];
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
    [rightLegendLabel setFrame:CGRectMake(self.bareChartView.frame.size.width - rightLegendLabel.frame.size.width, 0,
                                          rightLegendLabel.frame.size.width, rightLegendLabel.frame.size.height)];
    [fView addSubview:leftLegendLabel];
    [fView addSubview:rightLegendLabel];
    [fView addSubview:self.progressView];
    fView.backgroundColor = [UIColor lightGrayColor];
    [self.bareChartView addSubview:fView];
    
    CGFloat totalDurationInMinutes = [profile.duration floatValue];
    CGFloat pointsPerMinute = self.bareChartView.frame.size.width / totalDurationInMinutes;
    CGFloat xPos = 0.f;
    NSArray *lapsForProfile = [profile.laps allObjects];
    NSArray *orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];
    CGFloat oldIntensity = 0.f;
    CGFloat previousIntensity = 0.f;
    CGFloat previousDuration = 0.f;
    for (int i=0; i < profile.laps.count; i++) {
        Lap *thisLap = (Lap*)orderedLapsForProfile[i];
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
        
        NSLog(@"-thisLap lapStartSpeechString:%@", thisLap.lapStartSpeechString);
        CGFloat barWidth = ([thisLap.lapTime floatValue] / 60.0) * pointsPerMinute;
        CGFloat barHeight = [thisLap.lapIntensity floatValue] * 30.f;
        UIView *lapBarView = [[UIView alloc] initWithFrame:CGRectMake(xPos,
                                                                      self.bareChartView.frame.size.height - barHeight,
                                                                      barWidth,
                                                                      barHeight + 10.f)];
        xPos += barWidth;
        lapBarView.backgroundColor = [UIColor blueColor];
        [self.bareChartView addSubview:lapBarView];
        
        if (intensityDidIncrease) {
            UILabel *newIntensityLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos - (previousDuration*2), self.bareChartView.frame.size.height - (currentIntensity*30) - 29, 48, 24)];
            [newIntensityLabel setFont:[UIFont systemFontOfSize:12.f]];
            [newIntensityLabel setTextColor:[UIColor whiteColor]];
            [newIntensityLabel setBackgroundColor:[UIColor darkGrayColor]];
            newIntensityLabel.layer.cornerRadius = 3;
            newIntensityLabel.layer.masksToBounds = YES;
            newIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)currentIntensity];
            [newIntensityLabel sizeToFit];
//            [self.bareChartView addSubview:newIntensityLabel];
        }
        previousDuration = currentDuration;
    }
    
    [self.view addSubview:self.bareChartView];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

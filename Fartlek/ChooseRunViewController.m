//
//  ChooseRunViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 4/1/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "ChooseRunViewController.h"
#import "SetupFartlekViewController.h"
//#import "WorkoutViewController.h"
#import "CurrentWorkoutViewController.h"
#import <Bestly/Bestly.h>
#import <AFNetworking/AFNetworking.h>
#import "User+Database.h"
#import "Lap+Database.h"
#import "Run+Database.h"
#import "Profile+Database.h"
#import "NSObject+Conversions.h"
@import QuartzCore;
#import "RunManager.h"
#import "FartlekChartView.h"
#import "SetPaceViewController.h"

@interface ChooseRunViewController () <FartlekChartDelegate>
@property (strong, nonatomic) IBOutlet FartlekChartView *chartView;
@property (weak, nonatomic) IBOutlet UILabel *workoutSummaryLabel;
@property (strong, nonatomic) NSArray *orderedLapsForProfile;
@property (weak, nonatomic) IBOutlet UIButton *beginRunButton;
@end

@implementation ChooseRunViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Gotham-Book" size:20.0], NSFontAttributeName, nil];
    
    UIFont *joseFontBoldItalic22 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:22.f];
    [self.beginRunButton.titleLabel setFont:joseFontBoldItalic22];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:USER_SIGNED_IN_KEY]) {
        self.workoutSummaryLabel.text = @"";
    }
    [[RunManager sharedManager] resetManager];
    [self setupChart];
    
    [self fetchAction:nil];
}

- (void)setupChart
{
    self.chartView = [[RunManager sharedManager] chartViewForProfileCanEdit:YES];
    NSLog(@"chartView:%@", self.chartView);
    self.chartView.delegate = self;
    [self.view addSubview:self.chartView];
}

#pragma NETWORK ACTIVITY

- (IBAction)fetchAction:(id)sender
{
    self.currentProfile = nil;
    [Lap deleteAll];
    [Profile deleteAll];
    for (UIView *v in self.chartView.subviews) {
        [v removeFromSuperview];
    }
    [[DataManager sharedManager] markAllProfilesAsNotCurrent];
    
//    NSString *profileIntensity = self.workoutIntensityField.text;
//    int intensityIndex = [self.intensityPickerArray indexOfObject:profileIntensity]+1;
//    NSString *profileDuration = self.workoutLengthField.text;
    
    NSNumber *profileIntensityNumber = [[RunManager sharedManager] userIntensity];
    NSNumber *profileDurationNumber = [[RunManager sharedManager] userDuration];
    
    NSString *getURL = [NSString stringWithFormat:@"http://fartlek.herokuapp.com/profiles/all/%d/%d.json", [profileIntensityNumber intValue], [profileDurationNumber intValue]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //             NSLog(@"JSON: %@", responseObject[@"profiles"]);
             NSArray *profilesArray = (NSArray*)responseObject[@"profiles"];
             if ([profilesArray count] > 0) {
                 for (NSDictionary *profileAndLapsDict in profilesArray) {
                     NSArray *lapsArr = (NSArray*)profileAndLapsDict[@"laps"];
                     NSDictionary *profileDict = (NSDictionary*)profileAndLapsDict[@"profile"];
                     NSMutableArray *addedLaps = [NSMutableArray array];
                     [Lap createLapsWithGetProfileJSONFromServer:lapsArr
                                                 withProfileJSON:profileDict
                                                      appendedTo:addedLaps
                                                         success:
                      ^{
                          BOOL didAddLaps = NO;
                          if ([addedLaps count] > 0) {
                              didAddLaps = YES;
                          }
                          NSLog(@"PROFILE LAPS BUILD SUCCESS");
                          if (!self.currentProfile) {
                              self.currentProfile = [[DataManager sharedManager] findCurrentProfile];
                              NSLog(@"setting currentProfile to %@", self.currentProfile);
                              [[RunManager sharedManager] setCurrentProfile:self.currentProfile];
                              [self setupChart];
                          }
                      } failure:^(NSError *error) {
                          NSLog(@"PROFILE LAPS FAIL: %@", error.localizedDescription);
                      }];
                 }
             }
         }   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

#pragma mark - FartlekChartDelegate

- (void)didChangeProfileLeft
{
    int currentInt = [[[[RunManager sharedManager] currentProfile] versionNumber] intValue];
    int nextInt = currentInt - 1;
    [self changeProfile:nextInt];
}

- (void)didChangeProfileRight
{
    int currentInt = [[[[RunManager sharedManager] currentProfile] versionNumber] intValue];
    int nextInt = currentInt + 1;
    [self changeProfile:nextInt];
}

- (void)changeProfile:(int)nextProfileVersionNumber
{
    //    int profsCount = [[DataManager sharedManager] countOfProfilesWithDuration:self.currentProfile.duration
    //                                                                 andIntensity:self.currentProfile.intensity];
    Profile *prof = [[DataManager sharedManager] findProfileWithDuration:self.currentProfile.duration
                                                            andIntensity:self.currentProfile.intensity
                                                        andVersionNumber:@(nextProfileVersionNumber)];
    if (prof) {
        [[RunManager sharedManager] resetManager];
        [[RunManager sharedManager] setCurrentProfile:prof];
        NSLog(@"NEW PROFILE:(%@) %@", prof.profileName, prof);
        for (Lap *lap in prof.laps) {
            NSLog(@"lap:%@", lap);
        }
    } else {
        NSLog(@"NO NEW PROFILE");
    }
    
    [self.chartView removeFromSuperview];
    self.chartView = nil;
    self.chartView = [[RunManager sharedManager] chartViewForProfileCanEdit:YES];
    self.chartView.delegate = self;
    [self.view addSubview:self.chartView];
}

- (void)setupSummaryText
{
//    NSInteger lengthRow = [self.lengthPickerView selectedRowInComponent:0];
//    NSInteger intensityRow = [self.intensityPickerView selectedRowInComponent:0];
//    int paceMinuteInt = [[[RunManager sharedManager] userPaceMinutes] intValue];
//    int paceSecondInt = [[[RunManager sharedManager] userPaceSeconds] intValue];
//    float paceTotalInSeconds = paceMinuteInt*60.0 + paceSecondInt;
//    float workoutLengthInSeconds = [self.lengthPickerArray[lengthRow] floatValue]*60.0;
//    float runDistance = workoutLengthInSeconds / paceTotalInSeconds;
//    NSString *runDistanceString = [NSString stringWithFormat:@"%.2f", runDistance];
//    NSString *runtimeString = self.lengthPickerArray[lengthRow];
//    NSString *intensityString = self.intensityPickerArray[intensityRow];
//    NSString *summaryString = [NSString stringWithFormat:@"Your workout should last %@ minutes and cover about %@ miles at %@ intensity", runtimeString, runDistanceString, [intensityString lowercaseString]];
//    self.workoutSummaryLabel.text = summaryString;
}

- (IBAction)beginRun:(id)sender
{
//    NSDictionary *profileProperties = @{ @"duration" : self.workoutLengthField.text, @"intensity" : self.workoutIntensityField.text };
//    [Bestly trackEvent:@"START ACTION" withProperties:profileProperties];
    if ([[RunManager sharedManager] currentProfile]) {
        [self performSegueWithIdentifier:@"workoutSegue" sender:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Please Select a Profile" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

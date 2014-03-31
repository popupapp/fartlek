//
//  ViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

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

@interface SetupFartlekViewController () <UIPickerViewDataSource, UIPickerViewDelegate, FartlekChartDelegate>
@property (weak, nonatomic) IBOutlet UITextField *averagePaceField;
@property (weak, nonatomic) IBOutlet UITextField *workoutLengthField;
@property (weak, nonatomic) IBOutlet UITextField *workoutIntensityField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UILabel *workoutSummaryLabel;

@property (strong, nonatomic) UIPickerView *pacePickerView;
@property (strong, nonatomic) UIPickerView *lengthPickerView;
@property (strong, nonatomic) UIPickerView *intensityPickerView;

@property (strong, nonatomic) NSMutableArray *paceMinutePickerArray;
@property (strong, nonatomic) NSMutableArray *paceSecondPickerArray;
@property (strong, nonatomic) NSArray *lengthPickerArray;
@property (strong, nonatomic) NSArray *intensityPickerArray;

@property (strong, nonatomic) UIView *bareChartView;

@property (strong, nonatomic) NSArray *orderedLapsForProfile;
@property (strong, nonatomic) UIPinchGestureRecognizer *twoFingerPinch;

@property (strong, nonatomic) FartlekChartView *chartView;
@end

@implementation SetupFartlekViewController

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
    self.view.backgroundColor = FARTLEK_YELLOW;
    
    [self setupAveragePacePickerView];
    [self setupWorkoutLengthPickerView];
    [self setupWorkoutIntensityPickerView];
    [self setupSummaryText];
    
    [self.averagePaceField becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[RunManager sharedManager] resetManager];
    [self setupChart];
}

- (void)setupChart
{
    self.chartView = [[RunManager sharedManager] chartViewForProfileCanEdit:YES];
    self.chartView.delegate = self;
    [self.view addSubview:self.chartView];
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
    int profsCount = [[DataManager sharedManager] countOfProfilesWithDuration:self.currentProfile.duration
                                                                 andIntensity:self.currentProfile.intensity];
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

#pragma mark - Setup Picker Views

- (void)setupAveragePacePickerView
{
    self.paceMinutePickerArray = [NSMutableArray array];
    for (int i=1; i<16; i++) {
        [self.paceMinutePickerArray addObject:@(i)];
    }
    self.paceSecondPickerArray = [NSMutableArray array];
    for (int i=1; i<61; i++) {
        [self.paceSecondPickerArray addObject:@(i)];
    }
    
    self.pacePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [self.pacePickerView setDataSource: self];
    [self.pacePickerView setDelegate: self];
    self.pacePickerView.showsSelectionIndicator = YES;
    [self.pacePickerView selectRow:6 inComponent:0 animated:NO];
    [self.pacePickerView selectRow:14 inComponent:1 animated:NO];
    NSInteger minuteRow = [self.pacePickerView selectedRowInComponent:0];
    NSInteger secondRow = [self.pacePickerView selectedRowInComponent:1];
    NSString *timeString = [NSString stringWithFormat:@"%@m %@s", self.paceMinutePickerArray[minuteRow], self.paceSecondPickerArray[secondRow]];
    self.averagePaceField.text = timeString;

    self.averagePaceField.inputView = self.pacePickerView;
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                            CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignFR)];
    doneButton.tintColor = [UIColor redColor];
    [myToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    self.averagePaceField.inputAccessoryView = myToolbar;
}

- (void)setupWorkoutLengthPickerView
{
    self.lengthPickerArray = @[@30, @40, @50, @60, @75];
    self.lengthPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [self.lengthPickerView setDataSource: self];
    [self.lengthPickerView setDelegate: self];
    self.lengthPickerView.showsSelectionIndicator = YES;
    [self.lengthPickerView selectRow:0 inComponent:0 animated:NO];
    NSInteger selectedRowIndex = [self.lengthPickerView selectedRowInComponent:0];
    self.workoutLengthField.text = [[self.lengthPickerArray objectAtIndex:selectedRowIndex] toString];
    self.workoutLengthField.inputView = self.lengthPickerView;
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                            CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignFR)];
    doneButton.tintColor = [UIColor redColor];
    [myToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    self.workoutLengthField.inputAccessoryView = myToolbar;
}

- (void)setupWorkoutIntensityPickerView
{
    self.intensityPickerArray = @[@"Low", @"Medium", @"High"];
    self.intensityPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [self.intensityPickerView setDataSource:self];
    [self.intensityPickerView setDelegate:self];
    self.intensityPickerView.showsSelectionIndicator = YES;
    [self.intensityPickerView selectRow:0 inComponent:0 animated:NO];
    NSInteger selectedRowIndex = [self.intensityPickerView selectedRowInComponent:0];
    self.workoutIntensityField.text = [[self.intensityPickerArray objectAtIndex:selectedRowIndex] toString];
    self.workoutIntensityField.inputView = self.intensityPickerView;
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *doneButton =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignFR)];
    doneButton.tintColor = [UIColor redColor];
    [myToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    self.workoutIntensityField.inputAccessoryView = myToolbar;
}

- (void)resignFR
{
    [self.view endEditing:YES];
}

- (IBAction)startAction:(id)sender
{
    NSDictionary *profileProperties = @{ @"duration" : self.workoutLengthField.text, @"intensity" : self.workoutIntensityField.text };
    [Bestly trackEvent:@"START ACTION" withProperties:profileProperties];
    if ([[RunManager sharedManager] currentProfile]) {
        [self performSegueWithIdentifier:@"workoutSegue" sender:profileProperties];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Please Select a Profile" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

#pragma NETWORK ACTIVITY

- (IBAction)fetchAction:(id)sender
{
    self.currentProfile = nil;
//    [User deleteAll];
    [Lap deleteAll];
    [Profile deleteAll];
//    [Run deleteAll];
    for (UIView *v in self.bareChartView.subviews) {
        [v removeFromSuperview];
    }
    [[DataManager sharedManager] markAllProfilesAsNotCurrent];
    NSString *profileIntensity = self.workoutIntensityField.text;
    int intensityIndex = [self.intensityPickerArray indexOfObject:profileIntensity]+1;
    NSString *profileDuration = self.workoutLengthField.text;
    NSString *getURL = [NSString stringWithFormat:@"http://fartlek.herokuapp.com/profiles/all/%d/%@.json", intensityIndex, profileDuration];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"workoutSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[CurrentWorkoutViewController class]]) {
            // CurrentWorkoutViewController
        }
    }
}

#pragma mark - picker view stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:self.pacePickerView]) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.pacePickerView]) {
        if (component == 0) {
            return self.paceMinutePickerArray.count;
        } else {
            return self.paceSecondPickerArray.count;
        }
    } else if ([pickerView isEqual:self.lengthPickerView]) {
        return self.lengthPickerArray.count;
    } else if ([pickerView isEqual:self.intensityPickerView]) {
        return self.intensityPickerArray.count;
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.pacePickerView]) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%@ min", self.paceMinutePickerArray[row]];
        } else {
            return [NSString stringWithFormat:@"%@ sec", self.paceSecondPickerArray[row]];
        }
        return [NSString stringWithFormat:@"%@ min", self.paceMinutePickerArray[row]];
    } else if ([pickerView isEqual:self.lengthPickerView]) {
        return [NSString stringWithFormat:@"%@ min", self.lengthPickerArray[row]];
    } else if ([pickerView isEqual:self.intensityPickerView]) {
        return [NSString stringWithFormat:@"%@", self.intensityPickerArray[row]];
    } else {
        return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.pacePickerView]) {
        NSInteger minuteRow = [self.pacePickerView selectedRowInComponent:0];
        NSInteger secondRow = [self.pacePickerView selectedRowInComponent:1];
        NSString *timeString = [NSString stringWithFormat:@"%@m %@s", self.paceMinutePickerArray[minuteRow], self.paceSecondPickerArray[secondRow]];
        self.averagePaceField.text = timeString;
    } else if ([pickerView isEqual:self.lengthPickerView]) {
        self.workoutLengthField.text = [NSString stringWithFormat:@"%@", self.lengthPickerArray[row]];
    } else if ([pickerView isEqual:self.intensityPickerView]) {
        self.workoutIntensityField.text = [NSString stringWithFormat:@"%@", self.intensityPickerArray[row]];
    }
    [self setupSummaryText];
}

- (void)setupSummaryText
{
    NSInteger minuteRow = [self.pacePickerView selectedRowInComponent:0];
    NSInteger secondRow = [self.pacePickerView selectedRowInComponent:1];
    NSInteger lengthRow = [self.lengthPickerView selectedRowInComponent:0];
    NSInteger intensityRow = [self.intensityPickerView selectedRowInComponent:0];
    
    NSNumber *paceMinuteNumber = self.paceMinutePickerArray[minuteRow];
    NSNumber *paceSecondNumber = self.paceSecondPickerArray[secondRow];
    float paceTotalInSeconds = [paceMinuteNumber intValue]*60.0 + [paceSecondNumber intValue];
    float workoutLengthInSeconds = [self.lengthPickerArray[lengthRow] floatValue]*60.0;
    float runDistance = workoutLengthInSeconds / paceTotalInSeconds;
    NSString *runDistanceString = [NSString stringWithFormat:@"%.2f", runDistance];
    NSString *runtimeString = self.lengthPickerArray[lengthRow];
    NSString *intensityString = self.intensityPickerArray[intensityRow];
    
    NSString *summaryString = [NSString stringWithFormat:@"Your workout should last %@ minutes and cover about %@ miles at %@ intensity", runtimeString, runDistanceString, [intensityString lowercaseString]];
    self.workoutSummaryLabel.text = summaryString;
}

- (IBAction)deleteBBIAction:(id)sender
{
    [User deleteAll];
    [Lap deleteAll];
    [Profile deleteAll];
    [Run deleteAll];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

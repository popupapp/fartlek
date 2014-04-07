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
#import "SetPaceViewController.h"

@interface SetupFartlekViewController () <UIPickerViewDataSource, UIPickerViewDelegate, FartlekChartDelegate>
@property (weak, nonatomic) IBOutlet UITextField *workoutLengthField;
@property (weak, nonatomic) IBOutlet UITextField *workoutIntensityField;
@property (strong, nonatomic) UIPickerView *lengthPickerView;
@property (strong, nonatomic) UIPickerView *intensityPickerView;
@property (strong, nonatomic) NSArray *lengthPickerArray;
@property (strong, nonatomic) NSArray *intensityPickerArray;
@property (strong, nonatomic) UIView *bareChartView;
@property (strong, nonatomic) UIPinchGestureRecognizer *twoFingerPinch;

@property (weak, nonatomic) IBOutlet UILabel *readyForRunLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickDurationLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation SetupFartlekViewController

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
    
    [self setupWorkoutLengthPickerView];
    [self setupWorkoutIntensityPickerView];
    [[RunManager sharedManager] setUserIntensity:@(1)];
    [[RunManager sharedManager] setUserDuration:@(30)];
    
    UIFont *joseFontBoldItalic18 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:18.f];
    UIFont *joseFontBoldItalic22 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:22.f];
    UIFont *joseFontBoldItalic24 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:24.f];
    
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *userName = @"user";
    NSRange firstApostropheRange = [deviceName rangeOfString:@"'"];
    if (firstApostropheRange.location == NSNotFound) {
        // no apostrophe found in string
    } else {
        NSInteger firstApostropheLocation = firstApostropheRange.location;
        userName = [deviceName substringWithRange:NSMakeRange(0, firstApostropheLocation)];
    }
    self.readyForRunLabel.text = [NSString stringWithFormat:@"%@, are you ready to go for a fun run?", userName];
    
    [self.readyForRunLabel setFont:joseFontBoldItalic22];
    [self.pickDurationLabel setFont:joseFontBoldItalic18];
    [self.pickIntensityLabel setFont:joseFontBoldItalic18];
    [self.startButton.titleLabel setFont:joseFontBoldItalic24];
    [self.workoutLengthField setFont:joseFontBoldItalic22];
    [self.workoutIntensityField setFont:joseFontBoldItalic22];
    [self.workoutLengthField setTextColor:[UIColor whiteColor]];
    [self.workoutIntensityField setTextColor:[UIColor whiteColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USER_SIGNED_IN_KEY]) {
        // user has "signed in" and entered their run pace
        NSLog(@"WELCOME!");
    } else {
        // user hasn't yet "signed in" and entered their run pace
        [self performSegueWithIdentifier:@"setPaceSegue" sender:nil];
    }
}

- (IBAction)setMyPaceAction:(id)sender
{
    [self performSegueWithIdentifier:@"setPaceSegue" sender:nil];
}

- (IBAction)viewPastRunsAction:(id)sender
{
    [self performSegueWithIdentifier:@"runHistorySegue" sender:nil];
}

#pragma mark - unwind segue

-(IBAction)setPaceSegue:(UIStoryboardSegue*)unwindSegue
{
    if ([unwindSegue.sourceViewController isKindOfClass:[SetPaceViewController class]]) {
        SetPaceViewController *svc = (SetPaceViewController*)unwindSegue.sourceViewController;
        NSLog(@"(SetupFartlekVC - setPaceSegue) coming from SetPaceViewController with field text:%@", svc.averagePaceField.text);
    }
}

#pragma mark - Setup Picker Views

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
    [self performSegueWithIdentifier:@"chooseRunSegue" sender:nil];
}

#pragma mark - picker view stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.lengthPickerView]) {
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
    if ([pickerView isEqual:self.lengthPickerView]) {
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
    if ([pickerView isEqual:self.lengthPickerView]) {
        self.workoutLengthField.text = [NSString stringWithFormat:@"%@", self.lengthPickerArray[row]];
        [[RunManager sharedManager] setUserDuration:self.lengthPickerArray[row]];
    } else if ([pickerView isEqual:self.intensityPickerView]) {
        self.workoutIntensityField.text = [NSString stringWithFormat:@"%@", self.intensityPickerArray[row]];
        [[RunManager sharedManager] setUserIntensity:@(row+1)];
    }
//    [self setupSummaryText];
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

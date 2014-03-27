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
#import "JBLineChartView.h"
#import "User+Database.h"
#import "Lap+Database.h"
#import "Run+Database.h"
#import "Profile+Database.h"
#import "NSObject+Conversions.h"
@import QuartzCore;
#import "RunManager.h"

@interface SetupFartlekViewController () <UIPickerViewDataSource, UIPickerViewDelegate, JBLineChartViewDataSource, JBLineChartViewDelegate>
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

@property (strong, nonatomic) JBLineChartView *chartView;
@property (strong, nonatomic) UIView *bareChartView;

@property (strong, nonatomic) NSArray *orderedLapsForProfile;
@property (strong, nonatomic) UIPinchGestureRecognizer *twoFingerPinch;
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
    
    self.twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerPinch:)];
    
    [self setupAveragePacePickerView];
    [self setupWorkoutLengthPickerView];
    [self setupWorkoutIntensityPickerView];
    [self setupChart];
    [self setupSummaryText];
    
    [self.averagePaceField becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if ([[RunManager sharedManager] currentProfile]) {
        [[RunManager sharedManager] resetManager];
//    }
}

- (void)setupChart
{
    if (!self.currentProfile) {
        NSLog(@"!self.currentProfile");
    }
//    self.chartView = [JBLineChartView new];
//    self.chartView.delegate = self;
//    self.chartView.dataSource = self;
//    self.chartView.frame = CGRectMake(0, 324, 320, 155);
//    self.chartView.backgroundColor = [UIColor whiteColor];
    if (!self.bareChartView) {
        self.bareChartView = [[UIView alloc] initWithFrame:CGRectMake(0, 324, 320, 155)];
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
    fView.backgroundColor = [UIColor lightGrayColor];
    [self.bareChartView addSubview:fView];
    
    CGFloat totalDurationInMinutes = [self.currentProfile.duration floatValue];
    CGFloat pointsPerMinute = self.bareChartView.frame.size.width / totalDurationInMinutes;
    CGFloat xPos = 0.f;
    NSArray *lapsForProfile = [self.currentProfile.laps allObjects];
    self.orderedLapsForProfile = [[DataManager sharedManager] orderedLapsByLapNumber:lapsForProfile];
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
//            NSLog(@"%@",[NSString stringWithFormat:@"%d", (int)currentIntensity]);
//            [self.bareChartView addSubview:newIntensityLabel];
        }
        previousDuration = currentDuration;
    }
    
    [self.bareChartView addGestureRecognizer:self.twoFingerPinch];
    [self.view addSubview:self.bareChartView];
}

- (void)twoFingerPinch:(UIPinchGestureRecognizer *)recognizer
{
    NSLog(@"Pinch scale: %f", recognizer.scale);
    CGAffineTransform transform = CGAffineTransformMakeScale(recognizer.scale, recognizer.scale);
    // you can implement any int/float value in context of what scale you want to zoom in or out
    self.bareChartView.transform = transform;
}


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
    if (self.currentProfile) {
        NSLog(@"setting currentProfile to %@", self.currentProfile);
        [[RunManager sharedManager] setCurrentProfile:self.currentProfile];
        [self performSegueWithIdentifier:@"workoutSegue" sender:profileProperties];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Please Select a Profile" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

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
    NSString *getURL = [NSString stringWithFormat:@"http://fartlek.herokuapp.com/profiles/%d/%@.json", intensityIndex, profileDuration];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:getURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject[@"laps"]);
             NSArray *lapsArr = (NSArray*)responseObject[@"laps"];
             NSDictionary *profileDict = (NSDictionary*)responseObject[@"profile"];
             if ([lapsArr count] > 0) {
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
                      self.currentProfile = [[DataManager sharedManager] findCurrentProfile];
                      [self setupChart];
                  } failure:^(NSError *error) {
                      NSLog(@"PROFILE LAPS FAIL: %@", error.localizedDescription);
                  }];
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

#pragma mark - JBChart delegate stuff

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    // number of lines in chart
    return 1;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    // number of values for a line
    NSLog(@"lineIndex:%d", lineIndex);
    NSLog(@"number of this profile's laps: %d", self.currentProfile.laps.count);
//    return self.currentProfile.laps.count;
    return [self.currentProfile.duration intValue]; // xx minutes
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView
verticalValueForHorizontalIndex:(NSUInteger)x
             atLineIndex:(NSUInteger)lineIndex
{
    // x is the minute
    
    Lap *thisLap = self.orderedLapsForProfile[x];
    
    // current time + this lap's time
    int nextStopInMinutes = x + [thisLap.lapTime intValue];
    
    if (x < 10) {
        return 5;
    } else if (x < 20) {
        return 10;
    } else if (x < 30) {
        return 20;
    } else if (x < 40) {
        return 25;
    } else if (x < 50) {
        return 15;
    } else if (x < 60) {
        return 20;
    } else if (x < 70) {
        return 25;
    } else if (x < 80) {
        return 10;
    } else if (x < 90) {
        return 5;
    } else {
        return 0;
    }
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView
   colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    // color of line in chart
    return [UIColor redColor];

}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView
 widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    // width of line in chart
    return 2;
}

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView
              lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    // style of line in chart
    return JBLineChartViewLineStyleSolid;
}

- (UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    // color of selection view
    return [UIColor redColor];
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    // color of selected line
    return [UIColor blueColor];
}

- (void)lineChartView:(JBLineChartView *)lineChartView
 didSelectLineAtIndex:(NSUInteger)lineIndex
      horizontalIndex:(NSUInteger)horizontalIndex
           touchPoint:(CGPoint)touchPoint
{
    NSLog(@"didSelectLineAtIndex:%d, touchPoint:%@", lineIndex, NSStringFromCGPoint(touchPoint));
}

- (void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    NSLog(@"didUnselectLineInLineChartView");
}

#pragma mark - END chart view stuff

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

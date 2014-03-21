//
//  ViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "SetupFartlekViewController.h"
#import "WorkoutViewController.h"

@interface SetupFartlekViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *averagePaceField;
@property (weak, nonatomic) IBOutlet UITextField *workoutLengthField;
@property (weak, nonatomic) IBOutlet UITextField *workoutIntensityField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (strong, nonatomic) UIPickerView *pacePickerView;
@property (strong, nonatomic) UIPickerView *lengthPickerView;
@property (strong, nonatomic) UIPickerView *intensityPickerView;

@property (strong, nonatomic) NSMutableArray *paceMinutePickerArray;
@property (strong, nonatomic) NSMutableArray *paceSecondPickerArray;
@property (strong, nonatomic) NSArray *lengthPickerArray;
@property (strong, nonatomic) NSArray *intensityPickerArray;

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
    
    self.paceMinutePickerArray = [NSMutableArray array];
    for (int i=1; i<16; i++) {
        [self.paceMinutePickerArray addObject:@(i)];
    }
    self.paceSecondPickerArray = [NSMutableArray array];
    for (int i=1; i<61; i++) {
        [self.paceSecondPickerArray addObject:@(i)];
    }
    [self setupAveragePacePickerView];
    
    self.lengthPickerArray = @[@30, @40, @50, @60, @75];
    [self setupWorkoutLengthPickerView];
    
    self.intensityPickerArray = @[@"Low", @"Medium", @"High"];
    [self setupWorkoutIntensityPickerView];
}

- (void)setupAveragePacePickerView
{
    self.pacePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [self.pacePickerView setDataSource: self];
    [self.pacePickerView setDelegate: self];
    self.pacePickerView.showsSelectionIndicator = YES;
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
    self.lengthPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [self.lengthPickerView setDataSource: self];
    [self.lengthPickerView setDelegate: self];
    self.lengthPickerView.showsSelectionIndicator = YES;
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
    self.intensityPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [self.intensityPickerView setDataSource: self];
    [self.intensityPickerView setDelegate: self];
    self.intensityPickerView.showsSelectionIndicator = YES;
    self.workoutIntensityField.inputView = self.intensityPickerView;
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame:
                            CGRectMake(0, 0, 320, 44)];
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
    [self performSegueWithIdentifier:@"workoutSegue" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"workoutSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[WorkoutViewController class]]) {
            // WorkoutViewController
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
            return [NSString stringWithFormat:@"%@", self.paceMinutePickerArray[row]];
        } else {
            return [NSString stringWithFormat:@"%@", self.paceSecondPickerArray[row]];
        }
        return [NSString stringWithFormat:@"%@", self.paceMinutePickerArray[row]];
    } else if ([pickerView isEqual:self.lengthPickerView]) {
        return [NSString stringWithFormat:@"%@", self.lengthPickerArray[row]];
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
        self.averagePaceField.text = [NSString stringWithFormat:@"%@m %@s", self.paceMinutePickerArray[minuteRow], self.paceSecondPickerArray[secondRow]];
    } else if ([pickerView isEqual:self.lengthPickerView]) {
        self.workoutLengthField.text = [NSString stringWithFormat:@"%@", self.lengthPickerArray[row]];
    } else if ([pickerView isEqual:self.intensityPickerView]) {
        self.workoutIntensityField.text = [NSString stringWithFormat:@"%@", self.intensityPickerArray[row]];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

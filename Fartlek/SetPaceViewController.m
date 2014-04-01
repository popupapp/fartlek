//
//  SetPaceViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/31/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "SetPaceViewController.h"
#import "RunManager.h"

@interface SetPaceViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *upAndRunningLabel;
@property (weak, nonatomic) IBOutlet UILabel *comfortablePaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *minPerMileLabel;
@property (weak, nonatomic) IBOutlet UILabel *tapToEditLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@end

@implementation SetPaceViewController

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
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Gotham-Book" size:20.0], NSFontAttributeName, nil];
    self.view.backgroundColor = FARTLEK_YELLOW;
    
    UIFont *joseFontBoldItalic18 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:18.f];
    UIFont *joseFontBoldItalic22 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:22.f];
    UIFont *joseFontBoldItalic24 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:24.f];
    UIFont *joseFontBoldItalic20 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:20.f];
    UIFont *joseFontBoldItalic14 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:14.f];
    [self.upAndRunningLabel setFont:joseFontBoldItalic18];
    [self.comfortablePaceLabel setFont:joseFontBoldItalic24];
    [self.minPerMileLabel setFont:joseFontBoldItalic20];
    [self.averagePaceField setFont:joseFontBoldItalic24];
    [self.tapToEditLabel setFont:joseFontBoldItalic14];
    [self.startButton.titleLabel setFont:joseFontBoldItalic22];
    
    [self setupAveragePacePickerView];
    
    [self.averagePaceField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setPaceUnwind"]) {
        NSLog(@"SetPaceVC - prepareForSegue");
        [self.pacePickerView setDataSource:nil];
        [self.pacePickerView setDelegate:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_SIGNED_IN_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - setup picker view

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
    [self.pacePickerView setDataSource:self];
    [self.pacePickerView setDelegate:self];
    self.pacePickerView.showsSelectionIndicator = YES;
    [self.pacePickerView selectRow:6 inComponent:0 animated:NO];
    [self.pacePickerView selectRow:14 inComponent:1 animated:NO];
    NSInteger minuteRow = [self.pacePickerView selectedRowInComponent:0];
    NSInteger secondRow = [self.pacePickerView selectedRowInComponent:1];
    [[RunManager sharedManager] setUserPaceMinutes:self.paceMinutePickerArray[minuteRow]];
    [[RunManager sharedManager] setUserPaceSeconds:self.paceSecondPickerArray[secondRow]];
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

- (void)resignFR
{
    [self.view endEditing:YES];
}

#pragma mark - picker view stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.paceMinutePickerArray.count;
    } else {
        return self.paceSecondPickerArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if (component == 0) {
        return [NSString stringWithFormat:@"%@ min", self.paceMinutePickerArray[row]];
    } else {
        return [NSString stringWithFormat:@"%@ sec", self.paceSecondPickerArray[row]];
    }
    return [NSString stringWithFormat:@"%@ min", self.paceMinutePickerArray[row]];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    NSInteger minuteRow = [self.pacePickerView selectedRowInComponent:0];
    NSInteger secondRow = [self.pacePickerView selectedRowInComponent:1];
    NSString *timeString = [NSString stringWithFormat:@"%@m %@s", self.paceMinutePickerArray[minuteRow], self.paceSecondPickerArray[secondRow]];
    self.seconds = [self.paceSecondPickerArray[secondRow] intValue];
    self.minutes = [self.paceMinutePickerArray[minuteRow] intValue];
    [[RunManager sharedManager] setUserPaceMinutes:self.paceMinutePickerArray[minuteRow]];
    [[RunManager sharedManager] setUserPaceSeconds:self.paceSecondPickerArray[secondRow]];
    self.averagePaceField.text = timeString;
//    [self setupSummaryText];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

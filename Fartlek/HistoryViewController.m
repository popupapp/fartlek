//
//  HistoryViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "HistoryViewController.h"
#import "RunHistoryCell.h"
#import "Run+Database.h"
#import "Lap+Database.h"
#import "LapLocation+Database.h"
#import "Profile+Database.h"
#import "DataManager.h"
//#import "RunManager.h"
#import "WorkoutSummaryViewController.h"

@interface HistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *historyTable;
@property (weak, nonatomic) IBOutlet UILabel *runHistoryLabel;
@property (strong, nonatomic) NSArray *runHistoryArray;
@end

@implementation HistoryViewController


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
    
    UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    imgButton.frame = CGRectMake(0.0, 0.0, 35.f, 31.f);
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithCustomView:imgButton];
    [imgButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = b;
    
    UIFont *joseFontBoldItalic22 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:22.f];
    [self.runHistoryLabel setFont:joseFontBoldItalic22];
    
    [self setupRunHistoryData];
}

- (void)setupRunHistoryData
{
    self.runHistoryArray = [[DataManager sharedManager] findAllRuns];
    NSLog(@"number of runs: %d", self.runHistoryArray.count);
    [self.historyTable reloadData];
}

-(IBAction)backAction
{
//    if (self.navigationController) {
//        [self.navigationController popViewControllerAnimated:YES];
//    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
//    }
}


#pragma mark <UITableViewDataSource>

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.runHistoryArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"runHistoryCell"];
    Run *thisRun = self.runHistoryArray[indexPath.row];
    cell.profileNameLabel.text = [NSString stringWithFormat:@"%@", thisRun.profile.profileName];
    cell.lapsLabel.text = [NSString stringWithFormat:@"Laps: %d", thisRun.profile.laps.count];

    float runDistanceInMeters = [thisRun.runDistance floatValue];
    float runDistanceInMiles = runDistanceInMeters / METERS_PER_MILE;
    cell.distanceLabel.text = [NSString stringWithFormat:@"Distance: %.2f mi", runDistanceInMiles];
    
    float paceOfRun = [thisRun.runPace floatValue];
    float secondsTotal = paceOfRun * 60.f;
    int minutesPaceOfRun = secondsTotal / 60;
    int secondsPaceOfRun = (int)secondsTotal % 60;
    if (paceOfRun == INFINITY) {
        cell.runPaceLabel.text = @"Run Pace: 0:00 min/mi";
    } else {
        cell.runPaceLabel.text = [NSString stringWithFormat:@"Pace: %d:%.2d min/mi", minutesPaceOfRun, secondsPaceOfRun];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Run *thisRun = self.runHistoryArray[indexPath.row];
    [self performSegueWithIdentifier:@"runSummarySegue" sender:thisRun];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"runSummarySegue"]) {
        if ([segue.destinationViewController isKindOfClass:[WorkoutSummaryViewController class]]) {
            WorkoutSummaryViewController *wvc = (WorkoutSummaryViewController*)segue.destinationViewController;
            wvc.thisRun = (Run*)sender;
        }
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

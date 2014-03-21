//
//  WorkoutSummaryViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "WorkoutSummaryViewController.h"
#import "HistoryViewController.h"
#import "CurrentRunCell.h"

@interface WorkoutSummaryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *viewRouteButton;
@property (weak, nonatomic) IBOutlet UITableView *summaryTable;

@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@end

@implementation WorkoutSummaryViewController

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
}

- (IBAction)saveAction:(id)sender
{
    [self performSegueWithIdentifier:@"historySegue" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"historySegue"]) {
        if ([segue.destinationViewController isKindOfClass:[HistoryViewController class]]) {
            // HistoryViewController
        }
    }
}

#pragma mark <UITableViewDataSource>

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CurrentRunCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workoutSummaryLabelCell"];
    switch (indexPath.row) {
        case 0: {
            // avg pace
            cell.leftLabel.text = @"4th Gear Time:";
            cell.rightLabel.text = @"Value";
        }
            break;
        case 1: {
            // remaining time
            cell.leftLabel.text = @"3rd Gear Time:";
            cell.rightLabel.text = @"Value";
        }
            break;
        case 2: {
            // elapsed time
            cell.leftLabel.text = @"2nd Gear Time:";
            cell.rightLabel.text = @"Value";
        }
            break;
        case 3: {
            // distance
            cell.leftLabel.text = @"1st Gear Time:";
            cell.rightLabel.text = @"Value";
        }
            break;
        case 4: {
            // next lap
            cell.leftLabel.text = @"Total Distance:";
            cell.rightLabel.text = @"Value";
        }
            break;
        case 5: {
            // next lap
            cell.leftLabel.text = @"Total Time:";
            cell.rightLabel.text = @"Value";
        }
            break;
        case 6: {
            // next lap
            cell.leftLabel.text = @"Average Pace:";
            cell.rightLabel.text = @"Value";
        }
            break;
        case 7: {
            // next lap
            cell.leftLabel.text = @"Max Pace:";
            cell.rightLabel.text = @"Value";
        }
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

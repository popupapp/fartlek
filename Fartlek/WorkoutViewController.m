//
//  WorkoutViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "WorkoutViewController.h"
#import "WorkoutSummaryViewController.h"
#import "CurrentRunCell.h"
#import "FartlekDataImporter.h"

@interface WorkoutViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *gearLabel;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UITableView *currentLapTable;
@property (weak, nonatomic) IBOutlet UITableView *totalTable;
@property (strong, nonatomic) FartlekDataImporter *importer;
@end

@implementation WorkoutViewController


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
    
    self.importer = [[FartlekDataImporter alloc] init];
}

- (IBAction)pauseAction:(id)sender
{
    [self performSegueWithIdentifier:@"workoutSummarySegue" sender:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"workoutSummarySegue"]) {
        if ([segue.destinationViewController isKindOfClass:[WorkoutSummaryViewController class]]) {
            // WorkoutSummaryViewController
        }
    }
}

#pragma mark <UITableViewDataSource>

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.currentLapTable]) return 5;
    else return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.currentLapTable]) {
        // currentLap
        CurrentRunCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentLapLabelCell"];
        switch (indexPath.row) {
            case 0: {
                // avg pace
                cell.leftLabel.text = @"Average Pace:";
                cell.rightLabel.text = @"Value";
            }
                break;
            case 1: {
                // remaining time
                cell.leftLabel.text = @"Remaining Time:";
                cell.rightLabel.text = @"Value";
            }
                break;
            case 2: {
                // elapsed time
                cell.leftLabel.text = @"Elapsed Time:";
                cell.rightLabel.text = @"Value";
            }
                break;
            case 3: {
                // distance
                cell.leftLabel.text = @"Distance:";
                cell.rightLabel.text = @"Value";
            }
                break;
            case 4: {
                // next lap
                cell.leftLabel.text = @"Next Lap:";
                cell.rightLabel.text = @"Value";
            }
                break;
            default:
                break;
        }
        return cell;
    } else {
        // total
        CurrentRunCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lapTotalLabelCell"];
        switch (indexPath.row) {
            case 0: {
                // elapsed time
                cell.leftLabel.text = @"Elapsed Time:";
                cell.rightLabel.text = @"Value";
            }
                break;
            case 1: {
                // remaining time
                cell.leftLabel.text = @"Remaining Time:";
                cell.rightLabel.text = @"Value";
            }
                break;
            case 2: {
                // total distance
                cell.leftLabel.text = @"Total Distance:";
                cell.rightLabel.text = @"Value";
            }
                break;
            default:
                break;
        }
        return cell;
    }
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

//
//  WorkoutSummaryViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "WorkoutSummaryViewController.h"
#import "HistoryViewController.h"

@interface WorkoutSummaryViewController ()
@property (strong, nonatomic) IBOutlet UIButton *viewRouteButton;

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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

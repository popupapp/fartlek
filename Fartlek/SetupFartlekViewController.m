//
//  ViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "SetupFartlekViewController.h"
#import "WorkoutViewController.h"

@interface SetupFartlekViewController ()
@property (weak, nonatomic) IBOutlet UITextField *averagePaceField;
@property (weak, nonatomic) IBOutlet UITextField *workoutLengthField;
@property (weak, nonatomic) IBOutlet UITextField *workoutIntensityField;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

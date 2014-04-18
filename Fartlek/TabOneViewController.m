//
//  TabOneViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 4/15/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "TabOneViewController.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

@interface TabOneViewController ()
@property (weak, nonatomic) IBOutlet UITabBarItem *tabOneTabItem;

@end

@implementation TabOneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FAKFontAwesome *cameraIcon = [FAKFontAwesome cameraIconWithSize:30.f];
    [cameraIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *cameraIconImg = [cameraIcon imageWithSize:CGSizeMake(90, 90)];
    self.tabBarItem.image = cameraIconImg;
    self.tabBarItem.title = @"Capture";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

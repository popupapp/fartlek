//
//  TabTwoViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 4/15/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "TabTwoViewController.h"
#import <FontAwesomeKit/FontAwesomeKit.h>

@interface TabTwoViewController ()

@end

@implementation TabTwoViewController

- (void)awakeFromNib
{
    FAKIonIcons *imagesIcon = [FAKIonIcons imagesIconWithSize:30.f];
    [imagesIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imagesIconImg = [imagesIcon imageWithSize:CGSizeMake(90, 90)];
    self.tabBarItem.image = imagesIconImg;
    self.tabBarItem.title = @"Gallery";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

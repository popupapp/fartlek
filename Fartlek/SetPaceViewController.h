//
//  SetPaceViewController.h
//  Fartlek
//
//  Created by Jason Humphries on 3/31/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetPaceViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *averagePaceField;
@property (strong, nonatomic) NSMutableArray *paceMinutePickerArray;
@property (strong, nonatomic) NSMutableArray *paceSecondPickerArray;
@property (strong, nonatomic) UIPickerView *pacePickerView;
@property (assign, nonatomic) int seconds;
@property (assign, nonatomic) int minutes;
@end

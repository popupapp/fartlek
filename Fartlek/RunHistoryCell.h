//
//  RunHistoryCell.h
//  Fartlek
//
//  Created by Jason Humphries on 4/7/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *runPaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@end

//
//  CurrentRunCell.m
//  Fartlek
//
//  Created by Jason Humphries on 3/20/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "CurrentRunCell.h"

@implementation CurrentRunCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

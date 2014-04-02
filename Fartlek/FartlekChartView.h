//
//  FartlekChartView.h
//  Fartlek
//
//  Created by Jason Humphries on 3/28/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FartlekChartDelegate <NSObject>
- (void)didChangeProfileLeft;
- (void)didChangeProfileRight;
@end

@interface FartlekChartView : UIView
@property (nonatomic, strong) id <FartlekChartDelegate> delegate;
@property (strong, nonatomic) UIView *progressView;

@end

//
//  Run+Database.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Run.h"
#import "DataManager.h"

@interface Run (Database)

+ (id)findByRunID:(NSString *)runID;
+ (NSArray *)findAll;
+ (void)deleteAll;

@end

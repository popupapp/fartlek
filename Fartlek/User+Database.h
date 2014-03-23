//
//  User+Database.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "User.h"
#import "DataManager.h"

@interface User (Database)

+ (NSArray *)findAll;
+ (id)findByUserID:(NSString *)userID;
+ (void)deleteAll;

@end

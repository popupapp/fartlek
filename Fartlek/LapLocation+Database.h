//
//  LapLocation+Database.h
//  Fartlek
//
//  Created by Jason Humphries on 4/7/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "LapLocation.h"
#import "DataManager.h"

@interface LapLocation (Database)

+ (id)findByLapLocationID:(NSString *)lapLocationID;
+ (NSArray *)findAll;
+ (void)deleteAll;
- (void)saveSuccess:(void (^)(void))success
            failure:(void (^)(NSError *error))failure;

@end

//
//  Lap+Database.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "Lap.h"
#import "DataManager.h"

@interface Lap (Database)

+ (void)createLapsWithGetProfileJSONFromServer:(NSArray *)jsonArray
                               withProfileJSON:(NSDictionary*)profileJSON
                                    appendedTo:(NSMutableArray *)profileLaps
                                       success:(void (^)(void))success
                                       failure:(void (^)(NSError *error))failure;

+ (NSArray *)findAll;
+ (id)findByLapID:(NSString *)lapID;
+ (void)deleteAll;

@end

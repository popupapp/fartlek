//
//  FartlekUser.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FartlekUser : NSObject

#pragma mark - SINGLETON FOR CURRENT USER
+ (id)currentUser;

#pragma mark - DYNAMIC PROPERTIES
@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *email;

@end

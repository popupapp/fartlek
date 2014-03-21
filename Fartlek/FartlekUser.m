//
//  FartlekUser.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "FartlekUser.h"
#import "NSObject+Conversions.h"

static FartlekUser *g_user;

@interface FartlekUser ()
// gives you a setter in the private implementation only
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *email;
@end

@implementation FartlekUser

- (id)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

+ (id)currentUser
{
    if (!g_user) {
        g_user = [[self alloc] init];
    }
    return g_user;
}


#pragma mark - DYNAMIC PROPERTIES

- (NSString *)email
{
    if (![self persistedValueForKey:USER_KEY_EMAIL]) {
        return @"";
    } else {
        return [self persistedValueForKey:USER_KEY_EMAIL];
    }
}

- (void)setEmail:(NSString *)email
{
    [self persistValue:email forKey:USER_KEY_EMAIL];
}

- (NSString *)firstName
{
    return [self persistedValueForKey:USER_KEY_FIRST_NAME];
}

- (void)setFirstName:(NSString *)firstName
{
    [self persistValue:firstName forKey:USER_KEY_FIRST_NAME];
}

- (NSString *)lastName
{
    return [self persistedValueForKey:USER_KEY_LAST_NAME];
}

- (void)setLastName:(NSString *)lastName
{
    [self persistValue:lastName forKey:USER_KEY_LAST_NAME];
}

- (NSString *)userID
{
    if ([[self persistedValueForKey:USER_KEY_USER_ID] isKindOfClass:[NSNumber class]]) {
        NSString *newUserID = [[self persistedValueForKey:USER_KEY_USER_ID] toString];
        [self persistValue:newUserID forKey:USER_KEY_USER_ID];
    }
    return [self persistedValueForKey:USER_KEY_USER_ID];
}

- (void)setUserID:(NSString *)userID
{
    [self persistValue:userID forKey:USER_KEY_USER_ID];
}


#pragma mark - CONVENIENCE METHODS FOR NSUSERDEFAULTS AND NSNOTIFICATIONCENTER

- (id)persistedValueForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)persistValue:(id)value forKey:(NSString *)key
{
    if (value) {
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)notifyObservers:(NSString *)notificationName userInfo:(NSDictionary *)notificationUserInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:notificationUserInfo];
}



@end

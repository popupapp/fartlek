//
//  BLAPIConnectionManager.m
//  Bestly
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "BLAPIConnectionManager.h"

#import "NSDictionary+QueryString.h"

@interface BLAPIConnectionManager () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSString *APIKey;

@end

@implementation BLAPIConnectionManager

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [NSOperationQueue new];
        [_operationQueue setMaxConcurrentOperationCount:2];
    }
    return self;
}

+ (instancetype)manager {
    static BLAPIConnectionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

+ (void)setupWithKey:(NSString *)key {
    NSParameterAssert(key);
    [[self manager] setAPIKey:key];
}

#pragma mark - GET

- (void)GET:(NSString *)URLString
 parameters:(NSDictionary *)parameters
 completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSURLRequest *request = [self requestWithMethod:@"GET" URLString:URLString parameters:parameters];
    [self queueRequest:request
            completion:^(NSDictionary *response, NSError *error) {
                completion(response, error);
            }];
}

#pragma mark - POST

- (void)POST:(NSString *)URLString
  parameters:(NSDictionary *)parameters
  completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSURLRequest *request = [self requestWithMethod:@"POST" URLString:URLString parameters:parameters];
    [self queueRequest:request
            completion:^(NSDictionary *response, NSError *error) {
                completion(response, error);
            }];
}

#pragma mark - Generic URL Request

- (void)queueRequest:(NSURLRequest *)request
          completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *responseObject = [self responseObjectForResponse:response data:responseData error:&error];
        if (error)
            completion(nil, error);
        else if (response.statusCode > 299)
            completion(nil, [NSError errorWithDomain:@"com.bestly.http" code:response.statusCode userInfo:nil]);
        else
            completion(responseObject, nil);
    }];
    [operation setQueuePriority:NSOperationQueuePriorityNormal];
    [self.operationQueue addOperation:operation];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters {
    NSParameterAssert(method);
    NSParameterAssert(URLString);

    NSError *error = nil;
    NSString *finalURLString = URLString;
    NSData *HTTPBody = nil;

    if ([method isEqualToString:@"GET"]) {
        NSString *queryString = [parameters queryString];
        if (queryString)
            finalURLString = [NSString stringWithFormat:@"%@?%@", URLString, queryString];
    } else {
        HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error] ;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalURLString]];
    [request setHTTPMethod:method];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [HTTPBody length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: HTTPBody];

    NSString *loginString = [NSString stringWithFormat:@"%@:", self.APIKey];
    NSString *encodedLoginString = [[loginString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSString *authHeader = [@"Basic " stringByAppendingFormat:@"%@", encodedLoginString];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];

    if (error) NSLog(@"Bestly Error: %@", error.description);

    return request;
}

- (NSDictionary *)responseObjectForResponse:(NSHTTPURLResponse *)response
                                       data:(NSData *)data
                                      error:(NSError *__autoreleasing *)error {
    // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
    // See https://github.com/rails/rails/issues/1742
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    if (response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }

    id responseObject = nil;
    NSString *responseString = [[NSString alloc] initWithData:data encoding:stringEncoding];
    if (responseString && ![responseString isEqualToString:@" "]) {
        data = [responseString dataUsingEncoding:NSUTF8StringEncoding];

        if (data) {
            if ([data length] > 0) {
                responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
            } else {
                return nil;
            }
        }
    }
    return responseObject;
}

@end

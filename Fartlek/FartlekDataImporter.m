//
//  FartlekDataImporter.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "FartlekDataImporter.h"
#import "DataManager.h"
#import "NSObject+Conversions.h"
#import "Profile+Database.h"

@interface FartlekDataImporter () <CHCSVParserDelegate>
@property (assign, nonatomic) BOOL isParsingDocument;
@property (assign, nonatomic) NSInteger currentLineIndex;
@property (assign, nonatomic) NSInteger currentFieldIndex;
@property (assign, nonatomic) NSInteger currentProfileLineIndex;
@property (weak, nonatomic) NSMutableDictionary *currentProfileDict;
@property (weak, nonatomic) NSMutableDictionary *currentLapDict;
@property (weak, nonatomic) NSMutableArray *currentLapsArr;
@property (weak, nonatomic) Profile *currentProfile;
@property (weak, nonatomic) Lap *currentLap;
@property (assign, nonatomic) BOOL isParsingRoot;
@property (assign, nonatomic) BOOL isParsingName;
@end

@implementation FartlekDataImporter

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"scripted3"
                                                         ofType:@"csv"];
//        NSError *err;
//        NSString *content = [NSString stringWithContentsOfFile:path
//                                                      encoding:NSUTF8StringEncoding
//                                                         error:&err];
//        if (!err) {
            self.csvParser = [[CHCSVParser alloc] initWithContentsOfCSVFile:path];
            self.csvParser.delegate = self;
            self.csvParser.sanitizesFields = YES;
            self.isParsingDocument = NO;
            self.isParsingName = NO;
            self.isParsingRoot = NO;
            self.currentFieldIndex = 0;
            self.currentLineIndex = 0;
            dispatch_async(dispatch_queue_create("parsingCSV", NULL), ^{
                [self startParsing];
            });
//        } else {
//            NSLog(@"ERROR IMPORTING FILE. %@", err.localizedDescription);
//        }
    }
    return self;
}

- (void)startParsing
{
    NSLog(@"startParsing");
    [self.csvParser parse];
}

// DOCUMENT
- (void)parserDidBeginDocument:(CHCSVParser *)parser
{
    NSLog(@"begin document");
    self.isParsingDocument = YES;
}

- (void)parserDidEndDocument:(CHCSVParser *)parser
{
    NSLog(@"end document");
    self.isParsingDocument = NO;
    NSArray *profiles = [[DataManager sharedManager] findAllProfiles];
    NSArray *laps = [[DataManager sharedManager] findAllLaps];
    NSLog(@"\nprofiles:%d\nlaps:%d", profiles.count, laps.count);
    NSLog(@"boo");
}
// DOCUMENT

// LINE
- (void)parser:(CHCSVParser *)parser
  didBeginLine:(NSUInteger)recordNumber
{
    self.currentLineIndex = recordNumber;
    NSLog(@"begin line: %d", recordNumber);
}

- (void)parser:(CHCSVParser *)parser
  didReadField:(NSString *)field
       atIndex:(NSInteger)fieldIndex
{
    BOOL isThisEmpty = NO;
    self.currentFieldIndex = fieldIndex;
    if (field.length < 1) {
        NSLog(@"read empty field, at index %d", fieldIndex);
        isThisEmpty = YES;
    } else {
        NSLog(@"read field: %@, at index: %d", field, fieldIndex);
        isThisEmpty = NO;
    }
    if (!isThisEmpty) {
        if ([field isEqualToString:@"Profile"]) {
            // first line of this profile
            self.currentProfileLineIndex = 0;
        } else {
            // not first line. keep track of profile line.
            self.currentProfileLineIndex += 1;
        }
        
        if (self.currentProfileLineIndex == 0) {
            // profile line
        } else if (self.currentProfileLineIndex == 1) {
            // profile name line
            if (self.currentFieldIndex == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.currentProfile = [[DataManager sharedManager] createProfile];
                    self.currentProfile.profileName = field;
                });
            }
        } else {
            // lap line
            if (self.currentFieldIndex == 1) {
                // lapNumber
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.currentLap = [[DataManager sharedManager] createLap];
                });
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *myNumber = [f numberFromString:field];
                self.currentLap.lapNumber = myNumber;
            } else if (self.currentFieldIndex == 2) {
                // lapTime
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *myNumber = [f numberFromString:field];
                self.currentLap.lapTime = myNumber;
            } else if (self.currentFieldIndex == 3) {
                // lapIntensity
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *myNumber = [f numberFromString:field];
                self.currentLap.lapIntensity = myNumber;
            } else if (self.currentFieldIndex == 4) {
                // speechLine
                self.currentLap.lapStartSpeechString = field;
                // add lap to profile
                [self.currentProfile addLapsObject:self.currentLap];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[DataManager sharedManager] saveContextSuccess:^{
                        NSLog(@"SUCCESS saving MOC");
                    } failure:^(NSError *error) {
                        NSLog(@"FAILED saving MOC: %@", error.localizedDescription);
                    }];
                });
            }
        }
    }
}

- (void)parser:(CHCSVParser *)parser
    didEndLine:(NSUInteger)recordNumber
{
    NSLog(@"end line: %d", recordNumber);
    self.currentFieldIndex = 0;
    self.currentProfile = nil;
    self.currentLap = nil;
}
// LINE




- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error
{
    NSLog(@"ERROR PARSING: %@", error.localizedDescription);
}




@end

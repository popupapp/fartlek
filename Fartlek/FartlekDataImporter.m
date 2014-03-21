//
//  FartlekDataImporter.m
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "FartlekDataImporter.h"

@interface FartlekDataImporter () <CHCSVParserDelegate>
@property (assign, nonatomic) BOOL isParsingDocument;
@property (assign, nonatomic) NSInteger currentLineIndex;
@property (assign, nonatomic) NSInteger currentFieldIndex;

@end

@implementation FartlekDataImporter

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"scripted"
                                                         ofType:@"csv"];
        NSError *err;
        NSString *content = [NSString stringWithContentsOfFile:path
                                                      encoding:NSUTF8StringEncoding
                                                         error:&err];
        if (!err) {
            self.csvParser = [[CHCSVParser alloc] initWithContentsOfCSVFile:path];
            self.csvParser.delegate = self;
            self.csvParser.sanitizesFields = YES;
            self.isParsingDocument = NO;
            [self startParsing];
        } else {
            NSLog(@"ERROR IMPORTING FILE. %@", err.localizedDescription);
        }
    }
    return self;
}

- (void)startParsing
{
    NSLog(@"startParsing");
    [self.csvParser parse];
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser
{
    NSLog(@"did begin document");
    self.isParsingDocument = YES;
}

- (void)parserDidEndDocument:(CHCSVParser *)parser
{
    NSLog(@"did end document");
    self.isParsingDocument = NO;
}

- (void)parser:(CHCSVParser *)parser
  didBeginLine:(NSUInteger)recordNumber
{
    NSLog(@"did begin line: %d", recordNumber);
    self.currentLineIndex = recordNumber;
}

- (void)parser:(CHCSVParser *)parser
  didReadField:(NSString *)field
       atIndex:(NSInteger)fieldIndex
{
    NSLog(@"did read field: %@, at index: %d", field, fieldIndex);
    if (field.length < 1) {
        NSLog(@"\t this field is empty");
    } else {
        NSLog(@"\t this field contains: [%@]", field);
    }
    self.currentFieldIndex = fieldIndex;
}

- (void)parser:(CHCSVParser *)parser
    didEndLine:(NSUInteger)recordNumber
{
    NSLog(@"did begin line: %d", recordNumber);
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error
{
    NSLog(@"ERROR PARSING: %@", error.localizedDescription);
}




@end

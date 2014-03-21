//
//  FartlekDataImporter.h
//  Fartlek
//
//  Created by Jason Humphries on 3/21/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

@interface FartlekDataImporter : NSObject

@property (strong, nonatomic) CHCSVParser *csvParser;

@end

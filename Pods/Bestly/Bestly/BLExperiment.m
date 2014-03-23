//
//  BLExperiment.m
//  Bestly
//
//  Created by James Martinez on 1/16/14.
//  Copyright (c) 2014 Bestly, Inc. All rights reserved.
//

#import "BLExperiment.h"

#import "BLAPIConnectionManager.h"
#import "BLEvent.h"
#import "BLVariation.h"
#import "NSDictionary+PruneNull.h"

NSString *const kBestlyExperimentsEndpoint = @"http://best.ly/api/v1/experiments";
NSString *const kBestlyUserDefaultsSelectionsKey = @"com.bestly.bestly.selections";

@implementation BLExperiment

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        _id = dictionary[@"id"];
        for (NSDictionary *variationDictionary in dictionary[@"variations"]) {
            BLVariation *variation = [[BLVariation alloc] initWithDictionary:variationDictionary andExperiment:self];
            NSMutableArray *experimentVariations = [_variations mutableCopy];
            if (!experimentVariations) experimentVariations = [NSMutableArray array];
            [experimentVariations addObject:variation];
            _variations = [experimentVariations copy];
        }
    }
    return self;
}

#pragma mark - Get Experiments

+ (void)getExperiments {
    [[BLAPIConnectionManager manager] GET:kBestlyExperimentsEndpoint
                               parameters:nil
                               completion:^(NSDictionary *response, NSError *error) {
                                   if (error)
                                       NSLog(@"Bestly Error: %@", error.description);
                                   else {
                                       // Parse response
                                       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                           NSMutableArray *experiments = [NSMutableArray array];
                                           for (NSDictionary *experimentDictionary in response[@"experiments"]) {
                                               BLExperiment *experiment = [[BLExperiment alloc] initWithDictionary:[experimentDictionary withoutNullObjects]];
                                               [experiments addObject:experiment];
                                           }
                                           [self selectVariationsForExperiments:experiments];
                                           NSLog(@"Bestly - Experiments received. Ready to go.");
                                       });
                                   }
                               }];
}

+ (void)selectVariationsForExperiments:(NSArray *)experiments {
    // Find existing selections
    NSMutableDictionary *selections = [[self selections] mutableCopy];

    for (BLExperiment *experiment in experiments) {
        // Remove inactive experiment/variation selections and prevent
        // future selection into the inactive variation
        for (BLVariation *variation in experiment.variations) {
            if (![variation.status isEqualToString:@"active"]) {
                NSString *experimentIDForInactiveVariation = variation.experiment.id;
                if (experimentIDForInactiveVariation) [selections removeObjectForKey:experimentIDForInactiveVariation];
                NSMutableArray *experimentVariations = [experiment.variations mutableCopy];
                [experimentVariations removeObject:variation];
                [experiment setVariations:experimentVariations];
            }
        }
        // Select a random variation for the experiment, skipping experiments
        // that already have selections
        if (![[selections allKeys] containsObject:experiment.id]) {
            BLVariation *selectedVariation = [self randomWeightedVariationFromExperiment:experiment];
            if (selectedVariation) {
                NSDictionary *selectedVariationDictionary = [selectedVariation dictionaryWithValuesForKeys:@[@"id", @"number"]];
                [selections setObject:[selectedVariationDictionary withoutNullObjects] forKey:experiment.id];
            }
        }
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[[selections copy] withoutNullObjects] forKey:kBestlyUserDefaultsSelectionsKey];
    [userDefaults synchronize];
}

+ (BLVariation *)randomWeightedVariationFromExperiment:(BLExperiment *)experiment {
    NSUInteger randomNumber = arc4random_uniform(101);
    NSUInteger weightsTotal = 0;
    BLVariation *selectedVariation = [experiment.variations firstObject]; // sane default
    for (BLVariation *variation in experiment.variations) {
        weightsTotal += [variation.weight unsignedIntegerValue];
        if (randomNumber <= weightsTotal) {
            selectedVariation = variation;
            break;
        }
    }
    return selectedVariation;
}

+ (NSDictionary *)selections {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *selections = [userDefaults objectForKey:kBestlyUserDefaultsSelectionsKey];
    // Note: selections mapping is:
    // {EXPERIMENT_ID}: { id: {VARIATION_ID}, number: {VARIATION_NUMBER} }
    return (selections) ? selections : [NSDictionary dictionary];
}

#pragma mark - Run Experiments

+ (void)runExperimentWithID:(NSString *)experimentID
                     blocks:(NSArray *)blocks {
    NSParameterAssert(experimentID);
    NSParameterAssert(blocks);

    NSDictionary *variationDictionary = [[self selections] objectForKey:experimentID];
    BLVariation *variation = [BLVariation new];
    [variation setId:variationDictionary[@"id"]];
    [variation setNumber:variationDictionary[@"number"]];

    if ([blocks count] > 0) {
        NSUInteger choice = 1;
        choice = [variation.number unsignedIntegerValue];
        if (choice <= 0) {
            choice = 1; // Ensure variation num is > 0
        }
        NSUInteger blockIndex = choice-1; // Adjust for the variation numbers starting at 1
        if (blocks.count <= blockIndex) {
            blockIndex = 1; // Default to variation A to prevent an index crash
        }
        void(^completion)(void) = blocks[blockIndex];
        if (completion) {
            [BLEvent postVariationEventWithVariationID:variation.id];
            completion();
        }
    }
}

@end

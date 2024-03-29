//
//  WorkoutSummaryViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 3/19/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "WorkoutSummaryViewController.h"
@import MapKit;
@import CoreLocation;
#import "HistoryViewController.h"
#import "CurrentRunCell.h"
#import "Run+Database.h"
#import "Lap+Database.h"
#import "Profile+Database.h"
#import "RunLocation.h"

@interface WorkoutSummaryViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *summaryTable;
@property (strong, nonatomic) NSArray *lapsArray;
@property (weak, nonatomic) IBOutlet UILabel *runSummaryLabel;
@property (weak, nonatomic) IBOutlet MKMapView *runMapView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapsLabel;

@end

@implementation WorkoutSummaryViewController

- (void)awakeFromNib
{
    //
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"thisRun: %@", self.thisRun);
    NSArray *tempLapsArray = [self.thisRun.runLaps allObjects];
    self.lapsArray = [[DataManager sharedManager] orderedLapsByLapNumber:tempLapsArray];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Gotham-Book" size:20.0], NSFontAttributeName, nil];
    
    UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imgButton setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    imgButton.frame = CGRectMake(0.0, 0.0, 35.f, 31.f);
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithCustomView:imgButton];
    [imgButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = b;
    
    UIFont *joseFontBoldItalic20 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:20.f];
    UIFont *joseFontBoldItalic22 = [UIFont fontWithName:@"JosefinSans-BoldItalic" size:22.f];
    [self.runSummaryLabel setFont:joseFontBoldItalic22];
    [self.lapsLabel setFont:joseFontBoldItalic22];
    [self.distanceLabel setFont:joseFontBoldItalic20];
    [self.timeLabel setFont:joseFontBoldItalic20];
    [self.paceLabel setFont:joseFontBoldItalic20];
    
    [self setupTopStatsBox];
    [self setupMap];
    [self setupTable];
}

- (void)setupTopStatsBox
{
    float distInMeters = [self.thisRun.runDistance floatValue];
    float distInMiles = distInMeters / METERS_PER_MILE;
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %.2f mi", distInMiles];
    
    float paceOfRun = [self.thisRun.runPace floatValue];
    float secondsTotal = paceOfRun * 60.f;
    int minutesPaceOfRun = secondsTotal / 60;
    int secondsPaceOfRun = (int)secondsTotal % 60;
    if (paceOfRun == INFINITY) {
        self.paceLabel.text = @"Pace: 0:00 min/mi";
    } else {
        self.paceLabel.text = [NSString stringWithFormat:@"Pace: %d:%.2d min/mi", minutesPaceOfRun, secondsPaceOfRun];
    }

    
    float secondsInLap = 0;
    for (Lap *lap in self.thisRun.runLaps) {
        secondsInLap += [lap.lapElapsedSeconds floatValue];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %.1f min", secondsInLap/60.0];
}

- (void)setupMap
{
    RunLocation *firstRunLocation;
    NSArray *lapArray = [self.thisRun.runLaps allObjects];
    NSLog(@"number of laps: %d", lapArray.count);
    NSArray *orderedLapsArray = [[DataManager sharedManager] orderedLapsByLapNumber:lapArray];
    NSLog(@"number of ordered laps: %d", orderedLapsArray.count);
    NSMutableArray *polylineLocationsArray = [NSMutableArray array];
    int numberOfLocations = 0;
    
    /// LOOP THROUGH EACH LAP
    for (int i=0; i < orderedLapsArray.count; i++) {
        Lap *lap = (Lap*)orderedLapsArray[i];
        NSLog(@"i:%d, lapNumber:%d", i, [lap.lapNumber intValue]);
        // locationsArray contains a bunch of RunLocation objects
        NSArray *locationsArray = [NSKeyedUnarchiver unarchiveObjectWithData:lap.locationsArray];
        NSLog(@"locationsArray.count:%lu", (unsigned long)locationsArray.count);
        if (i==0) {
            firstRunLocation = locationsArray[i];
        }
//        [self.runMapView addAnnotations:locationsArray];
//        [self.runMapView showAnnotations:locationsArray animated:YES];
        
        // LOOP THROUGH THE ARRAY OF THIS LAP'S LOCATIONS AND ADD TO THE MAIN POLYLINE ARRAY
            // !! ONLY IF IT'S THE LAST LAP (TEMP FIX)
        for (int j=0; j<locationsArray.count; j++) {
            if (j % 5 == 0) {
                RunLocation *thisRunLoc = locationsArray[j];
                NSLog(@"numberOfLocations: %d", numberOfLocations);
                numberOfLocations += 1;
                [polylineLocationsArray addObject:thisRunLoc];
            }
        }
        locationsArray = nil;
    }
    // END OF LOOPING THROUGH EACH LAP
    
    MKMapPoint *pointArr = malloc(sizeof(MKMapPoint) * numberOfLocations);
    
    // LOOP THROUGH THE ARRAY OF LOCATIONS ACCUMULATED FROM THE WHOLE RUN
    for (int i=0; i<polylineLocationsArray.count; i++) {
        RunLocation *runLoc = polylineLocationsArray[i];
        NSLog(@"--->timestamp:%d [%.3f,%.3f], %@", i, [runLoc.lat floatValue], [runLoc.lng floatValue], runLoc.timestamp);
        pointArr[i] = MKMapPointForCoordinate(runLoc.coordinate);
    }
    
    // CREATE LINE WITH pointArr LOCATIONS THEN ADD IT TO MAP
    MKPolyline *runMapLine = [MKPolyline polylineWithPoints:pointArr count:numberOfLocations];
    [self.runMapView removeOverlays:self.runMapView.overlays];
    [self.runMapView addOverlay:runMapLine];
    free(pointArr);
    
    float lat = [firstRunLocation.lat floatValue];
    float lng = [firstRunLocation.lng floatValue];
    [self zoomToThisLat:lat Lon:lng];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 1.0;
        return renderer;
    } else {
        return nil;
    }
}

- (void)setupTable
{
    [self.summaryTable reloadData];
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark <UITableViewDataSource>

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
    return 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lapsArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CurrentRunCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workoutSummaryLabelCell"];
    Lap *thisLap = (Lap*)self.lapsArray[indexPath.row];
//    NSLog(@"thisLap:%@", thisLap);
    cell.leftLabel.text = [NSString stringWithFormat:@"Lap %d", indexPath.row];
    cell.rightLabel.text = [NSString stringWithFormat:@"%f m", [thisLap.lapDistance floatValue]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - map action

-(void)zoomToThisLat:(float)lat
                 Lon:(float)lon
{
    // pan to this location
    MKCoordinateRegion region;
    CLLocationCoordinate2D center;
    center.latitude = lat;
    center.longitude = lon;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.002f;
    span.longitudeDelta = 0.002f;
    region.center = center;
    region.span = span;
    [self.runMapView setRegion:region animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

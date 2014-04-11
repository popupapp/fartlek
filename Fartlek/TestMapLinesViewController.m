//
//  TestMapLinesViewController.m
//  Fartlek
//
//  Created by Jason Humphries on 4/10/14.
//  Copyright (c) 2014 PopUp Inc. All rights reserved.
//

#import "TestMapLinesViewController.h"
@import MapKit;
@import CoreLocation;
#import "RunLocation.h"

@interface TestMapLinesViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation TestMapLinesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMap];
}

- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)setupMap
{
    NSMutableArray *locationsArray = [NSMutableArray array];
    
    // build locationsArray
    RunLocation *loc1 = [RunLocation new];
    // colonial grand rtp
    loc1.lat = @(35.9409076);
    loc1.lng = @(-78.863088);
    [locationsArray addObject:loc1];
    // au@main
    RunLocation *loc2 = [RunLocation new];
    loc2.lat = @(35.995602);
    loc2.lng = @(-78.902153);
    [locationsArray addObject:loc2];
    // atc
    RunLocation *loc4 = [RunLocation new];
    loc4.lat = @(35.9933997);
    loc4.lng = @(-78.9042923);
    [locationsArray addObject:loc4];
    // fitch house
    RunLocation *loc3 = [RunLocation new];
    loc3.lat = @(35.862593);
    loc3.lng = @(-78.720292);
    [locationsArray addObject:loc3];
//    locationsArrayTwo
    NSData *locationsArrayData = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:[locationsArray copy]]];
    NSArray *locationsArrayTwo = [NSKeyedUnarchiver unarchiveObjectWithData:locationsArrayData];
    
    MKMapPoint *pointArr = malloc(sizeof(MKMapPoint) * locationsArrayTwo.count);
    int numberOfLocations = 0;
    for (int i=0; i < locationsArrayTwo.count; i++) {
        RunLocation *thisRunLoc = locationsArrayTwo[i];
        numberOfLocations += 1;
        pointArr[i] = MKMapPointForCoordinate(thisRunLoc.coordinate);
    }
    MKPolyline *runMapLine = [MKPolyline polylineWithPoints:pointArr count:numberOfLocations];
    [self.mapView addOverlay:runMapLine];
    free(pointArr);
    
    RunLocation *firstRunLocation = [RunLocation new];
    firstRunLocation.lat = @(35.9409076);
    firstRunLocation.lng = @(-78.863088);
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
    [self.mapView setRegion:region animated:YES];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

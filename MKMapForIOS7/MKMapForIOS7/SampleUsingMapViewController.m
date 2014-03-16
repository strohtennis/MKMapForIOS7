//
//  ViewController.m
//  MKMapForIOS7
//
//  Created by Eric Stroh on 9/1/13.
//  CapTech Consulting
//  Copyright (c) 2013 Eric Stroh. All rights reserved.
//

#import "SampleUsingMapViewController.h"
#import "CustomAnnotationView.h"
#import "CustomPointAnnotation.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>



@interface SampleUsingMapViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKDirectionsResponse* response;
@end

@implementation SampleUsingMapViewController{
    CLLocationCoordinate2D ravensLocation;
    CLLocationCoordinate2D steelersLocation;
    CLLocationCoordinate2D bengalsLocation;
    CLLocationCoordinate2D brownsLocation;
    MKPolygon *stadiumsPolygon;
    MKPolyline *polyLine;
    MKGeodesicPolyline *geoPolyLine;
    BOOL mapOverlayShowing;
    BOOL polyLineShowing;
    BOOL geoPolyLineShowing;
    MKPointAnnotation *pointParking;
    MKPointAnnotation *pointStadium;

    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    mapOverlayShowing = NO;
    geoPolyLineShowing = NO;
    polyLineShowing = NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.delegate = self;
    [self setStadiumValues];
}

-(void)setStadiumValues{
    ravensLocation.latitude = 39.277778;
    ravensLocation.longitude = -76.622665;
    steelersLocation.latitude = 40.446868;
    steelersLocation.longitude = -80.016637;
    bengalsLocation.latitude = 39.095200;
    bengalsLocation.longitude = -84.516170;
    brownsLocation.latitude = 41.505155;
    brownsLocation.longitude = -81.698791;
}

#pragma mark Map Annotations

//user pushed annotation buttons, create annotations and change the mapView to show them
- (IBAction)showAnnotationsPushed:(id)sender {
    MKPointAnnotation *pointRavens =[self createMapAnnotationForCoordinate:ravensLocation andTitle:@"Ravens" andAddress:@"1101 Russell St, Baltimore"];
    MKPointAnnotation *pointSteelers =[self createMapAnnotationForCoordinate:steelersLocation andTitle:@"Steelers" andAddress:@"100 Art Rooney Ave, Pittsburgh"];
    MKPointAnnotation *pointBengals =[self createMapAnnotationForCoordinate:bengalsLocation andTitle:@"Bengals" andAddress:@"6 Paul Brown Stadium, Cincinnati"];
    MKPointAnnotation *pointBrowns =[self createMapAnnotationForCoordinate:brownsLocation andTitle:@"Browns" andAddress:@"100 Alfred Lerner Way  Cleveland"];
    [_mapView showAnnotations:@[pointRavens,pointSteelers,pointBengals, pointBrowns] animated:NO];
    if(pointParking){//remove the annotation for local points in Baltimore if showing
        [_mapView removeAnnotations:@[pointParking, pointStadium]];
    }
    
}

-(MKPointAnnotation *)createMapAnnotationForCoordinate:(CLLocationCoordinate2D) coord andTitle:(NSString *)title andAddress:(NSString *)address{
    CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
    annotation.coordinate = coord;
    annotation.title = title;
    annotation.address = address;
    return annotation;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    CustomAnnotationView *view = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPin"];
    return view;
}


#pragma mark Draw Polylines
- (IBAction)drawPolylineTouched:(id)sender {
    [self placePolyLineOverlay];
}
- (IBAction)drawGeoPolylineTouched:(id)sender {
    [self placeGeoPolyLineOverlay];
}
-(void)placePolyLineOverlay{
    if(!polyLineShowing){
        CLLocationCoordinate2D points[2];
        points[0]=ravensLocation;
        points[1]=bengalsLocation;
        polyLine = [MKPolyline polylineWithCoordinates:points count:2];
        [_mapView addOverlay:polyLine];
        polyLineShowing = YES;
    }
    else{
        [_mapView removeOverlay:polyLine];
        polyLineShowing = NO;
    }
}
-(void)placeGeoPolyLineOverlay{
    if(!geoPolyLineShowing){
        CLLocationCoordinate2D points[3];
        points[0]=ravensLocation;
        points[1]=bengalsLocation;
        geoPolyLine = [MKGeodesicPolyline polylineWithCoordinates:points count:2];
        [_mapView addOverlay:geoPolyLine];
        geoPolyLineShowing = YES;
    }
    else{
        [_mapView removeOverlay:geoPolyLine];
        geoPolyLineShowing = NO;
    }
}

#pragma mark MapOverlay
- (IBAction)mapOverlayPressed:(id)sender {
    
    [self placeMapOverlay];
}


-(void)placeMapOverlay{
    if(!mapOverlayShowing){
        CLLocationCoordinate2D parkCrds[4] ;
        
        parkCrds[0]= ravensLocation;
        parkCrds[1]= steelersLocation;
        parkCrds[2]= bengalsLocation;
        parkCrds[3]= brownsLocation;
        
        stadiumsPolygon = [MKPolygon polygonWithCoordinates:parkCrds count:4];
        [_mapView addOverlay:stadiumsPolygon level:MKOverlayLevelAboveRoads];//try using AboveLabels
        mapOverlayShowing = YES;
    }
    else{
        [_mapView removeOverlay:stadiumsPolygon];
        mapOverlayShowing = NO;
    }
}



//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
// Now deprecated, change all MKOverlayView to MKOverlayRenderer
// Also change items such as MKPolygonView to MKPolygonRenderer
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    UIColor *purpleColor = [UIColor colorWithRed:0.149f green:0.0f blue:0.40f alpha:1.0f];
     UIColor *halfPurpleColor = [UIColor colorWithRed:0.149f green:0.0f blue:0.40f alpha:0.5f];
    UIColor *halfBlackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    if(overlay ==stadiumsPolygon){
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonRenderer.strokeColor =halfBlackColor;
        polygonRenderer.fillColor =halfPurpleColor;
        return polygonRenderer;
    }
    else if(overlay==polyLine || overlay==geoPolyLine){
        MKPolylineRenderer *polylineRender = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRender.lineWidth = 3.0f;
        UIColor *lineColor=[UIColor redColor];
        if(overlay == polyLine){
            lineColor = purpleColor;
        }
        polylineRender.strokeColor = lineColor;
        return polylineRender;
    }
    else{//directions
        MKPolylineRenderer *polylineRender = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineRender.lineWidth = 3.0f;
        UIColor *lineColor=[UIColor blueColor];
        polylineRender.strokeColor = lineColor;
        return polylineRender;
    }

}

#pragma mark Directions
- (IBAction)directionsTouched:(id)sender {
    [self createMapItems];
}

//creating map items to establish direction to Ravens stadium from a nearby parking garage
-(void)createMapItems{
    [_mapView removeOverlay:polyLine];
    [_mapView removeOverlay:geoPolyLine];
    [_mapView removeOverlay:stadiumsPolygon];
    mapOverlayShowing = NO;
    geoPolyLineShowing= NO;
    polyLineShowing = NO;
    
    NSDictionary *address = @{
                              (NSString *)kABPersonAddressStreetKey: @"1101 Russell St",
                              (NSString *)kABPersonAddressCityKey: @"Baltimore",
                              (NSString *)kABPersonAddressStateKey: @"MD",
                              (NSString *)kABPersonAddressZIPKey: @"21230",
                              (NSString *)kABPersonAddressCountryCodeKey: @"US"
                              };
    
    MKPlacemark *place = [[MKPlacemark alloc] 
                          initWithCoordinate:ravensLocation addressDictionary:address];
    MKMapItem *ravensStadium = [[MKMapItem alloc] initWithPlacemark:place];
    
    CLLocationCoordinate2D coordsGarage =
    CLLocationCoordinate2DMake(39.287546, -76.619355);
    
    NSDictionary *address2 = @{
                              (NSString *)kABPersonAddressStreetKey: @"300 West Lombard Street",
                              (NSString *)kABPersonAddressCityKey: @"Baltimore",
                              (NSString *)kABPersonAddressStateKey: @"MD",
                              (NSString *)kABPersonAddressZIPKey: @"21201",
                              (NSString *)kABPersonAddressCountryCodeKey: @"US"
                              };
    
    MKPlacemark *place2 = [[MKPlacemark alloc]
                          initWithCoordinate:coordsGarage addressDictionary:address2];
    MKMapItem *parkingGarage = [[MKMapItem alloc] initWithPlacemark:place2];
    pointParking =[self createMapAnnotationForCoordinate:coordsGarage andTitle:@"Parking" andAddress:@"300 West Lombard Street"];
    pointStadium =[self createMapAnnotationForCoordinate:ravensLocation andTitle:@"Ravens" andAddress:@"1101 Russell St, Baltimore"];
    [_mapView showAnnotations:@[pointParking,pointStadium] animated:NO];
    CLLocationCoordinate2D blimpCoord =
    CLLocationCoordinate2DMake(39.253095, -76.6657);
    MKMapCamera *camera =[MKMapCamera cameraLookingAtCenterCoordinate:coordsGarage fromEyeCoordinate:blimpCoord eyeAltitude:100];
    
    _mapView.pitchEnabled = YES;
    _mapView.showsBuildings= YES;
    _mapView.camera = camera;
    
    [self findDirectionsFrom:parkingGarage to:ravensStadium];
    
}

- (void)findDirectionsFrom:(MKMapItem *)source
                        to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = YES;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    __weak SampleUsingMapViewController *weakSelf = self;
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"Error is %@",error);
         } else {
             [weakSelf showDirections:response];
             
         }
     }];
}

//shows the routes on the mapView
- (void)showDirections:(MKDirectionsResponse *)response
{
    self.response = response;
    for (MKRoute *route in _response.routes) {
        [_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
    
}

#pragma mark Snapshot

- (IBAction)takeASnapshotPressed:(id)sender {
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.size = CGSizeMake(400, 400);
    options.scale = [[UIScreen mainScreen] scale];
    options.camera = _mapView.camera;
    options.mapType = MKMapTypeStandard;
    MKMapSnapshotter *snapshotter =
    [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error)
     {
         if (error){
             NSLog(@"Error is %@",error);
         }
         else{
             UIImageWriteToSavedPhotosAlbum(snapshot.image, nil, nil, nil);
         }
     }];

}



#pragma mark - Clean Up

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

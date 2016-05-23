//
//  MapSelectionViewController.m
//
//
//  Created by Seth on 11/12/15.
//  Copyright © 2015 arnottindustriesinc. All rights reserved.
//

#import "MapSelectionViewController.h"
#import <MapKit/MapKit.h>
#import "UIView+Extensions.h"

#import "SDActivityIndicatorMessageView.h"

@interface MapSelectionViewController ()<CLLocationManagerDelegate, MKMapViewDelegate>
{
    BOOL performingRevGeocoding;
    NSError *geocodeError;
    CLGeocoder *geoCoder;
    CLPlacemark *placemark;
}
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, assign) BOOL didCenterOnUserLocation;
@property (nonatomic, assign) BOOL isProcessingPlacemark;

@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, strong) MKPointAnnotation *touchPin;


// instruction banner
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_banner_top;

// activity indicator (sometimes it takes awhile to resolve for some reason
@property (nonatomic, strong) SDActivityIndicatorMessageView *activityIndicatorView;

@end


//helper method to get the rect in the map for an array of points
MKMapRect MapRectBoundingMapPoints(MKMapPoint points[], NSUInteger pointCount){
    double minX = INFINITY, maxX = -INFINITY, minY = INFINITY, maxY = -INFINITY;
    NSInteger i;
    for (i = 0; i < pointCount; i++) {
        MKMapPoint p = points[i];
        minX = MIN(p.x, minX);
        minY = MIN(p.y, minY);
        maxX = MAX(p.x, maxX);
        maxY = MAX(p.y, maxY);
    }
    return MKMapRectMake(minX, minY, maxX - minX,  maxY - minY);
    
}



@implementation MapSelectionViewController

-(void) dealloc
{
    _locationManager = nil;
    self.location = nil;
    self.touchPin = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.didCenterOnUserLocation = NO;
    self.isProcessingPlacemark = NO;
    
    self.mapView.mapType  = MKMapTypeStandard;
    self.mapView.delegate = self;
    
    
    UILongPressGestureRecognizer *lpgr  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration           = 0.6;
    [self.mapView addGestureRecognizer:lpgr];
    
}



- (IBAction)showMyLocation:(id)sender
{
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.mapView.showsUserLocation = !self.mapView.showsUserLocation;
}

-(IBAction)actionHideBanner:(id)sender
{
    // animate banner closed
    NSInteger bannerHeight = self.bannerView.bounds.size.height;
    self.constraint_banner_top.constant = -bannerHeight;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }completion:^(BOOL finished) {
                         [self.bannerView removeFromSuperview];
                         self.bannerView = nil;
                     }];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    MapSelectionViewController *__weak weakself = self;
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    if (self.isProcessingPlacemark)
    {
        return;
    }
    
    // we're processing, prevent multiple process requests (can cause multiple alert view presentation issues otherwise)
    self.isProcessingPlacemark = YES;
    
    // get touch location
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    
    // convert the touch location to coordinates
    self.coordinates = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    self.location    = [[CLLocation alloc] initWithLatitude:self.coordinates.latitude
                                                  longitude:self.coordinates.longitude];
    
    geoCoder = [[CLGeocoder alloc]init];
    
    [self showActivitySpinnerWithTitle:@"Looking up location..."];
    
    [geoCoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!error && [placemarks count] > 0)
         {
             placemark = [placemarks lastObject];
         }
         
         
         NSString *locationString = @"";
         if (placemark)
         {
             [self hideActivitySpinner];
             
//            NSLog(@"ADDRESS: %@", [self stringFromPlacemark:placemark]);
             NSString *cityState = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
             locationString = [NSString stringWithFormat:@"%@ - %@", cityState, placemark.country];

             NSLog(@"Location: [%@]", locationString);
             
             self.touchPin = [[MKPointAnnotation alloc] init];
             self.touchPin.coordinate = self.coordinates;
             self.touchPin.title = cityState;
             self.touchPin.subtitle = placemark.country;
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [self.mapView addAnnotation:self.touchPin];
                 
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:locationString
                                                                                message:@"Would you like to use this location?"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"Yes"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     
                                                                     // update tracker
                                                                     self.isProcessingPlacemark = NO;
                                                                     
                                                                     if (self.mapSelectCompletion)
                                                                     {
                                                                         self.mapSelectCompletion(@(self.coordinates.latitude), @(self.coordinates.longitude), locationString);
                                                                     }
                                                                 });
                                                             }];
                 
                 UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                                  style:UIAlertActionStyleCancel
                                                                handler:^(UIAlertAction * _Nonnull action) {
                                                                    self.isProcessingPlacemark = NO;
                                                                }];
                 
                 // add alert actions
                 [alert addAction:actionYes];
                 [alert addAction:cancel];
                 
                 // present alert
                 alert.popoverPresentationController.sourceView = weakself.view;
                 [weakself presentViewController:alert animated:YES completion:nil];
             });
             

         }
         else
         {
             [self showActivitySpinnerWithTitle:@"Lookup failed, try again..."];
             
             [self performSelector:@selector(hideActivitySpinner) withObject:nil afterDelay:2.0];
             
             NSLog(@"Error, nil placemark: [%@]", error);
             self.isProcessingPlacemark = NO;
         }
         
         
     }];

}




-(void) showActivitySpinnerWithTitle:(NSString*)title
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (!_activityIndicatorView)
                       {
                           UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
                           
                           _activityIndicatorView = [[SDActivityIndicatorMessageView alloc] initWithFrame:CGRectMake(0, 0, 200, 120)];
                           _activityIndicatorView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
                           _activityIndicatorView.center = window.center;
                           _activityIndicatorView.layer.cornerRadius = 20;
                           
                           [window addSubview:_activityIndicatorView];
                       }
                       
                       if (title)
                       {
                           [_activityIndicatorView setTitle:title];
                       }
                       
                   });
}

-(void) hideActivitySpinner
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    if (self.activityIndicatorView)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.activityIndicatorView removeFromSuperview];
                           self.activityIndicatorView = nil;
                       });
    }
}









#pragma mark MKMapViewDelegate Methods

// annotation selection
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationView");
}


// location updates
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    NSLog(@"mapViewWillStartLocatingUser");
}
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    NSLog(@"mapViewDidStopLocatingUser");
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation");
    if (! self.didCenterOnUserLocation)
    {
        self.didCenterOnUserLocation = YES;
        [self centerMapOnLocation:userLocation];
    }
}
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"didFailToLocateUserWithError");
}







#pragma mark - Helper Methods

-(void) centerMapOnLocation:(MKUserLocation*)userLocation
{
    MKCoordinateRegion region;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}









-(UIButton*) editingButtonWithSelector:(SEL)selector title:(NSString*)fontAwesomeString color:(UIColor*)color
{
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [editBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTitle:fontAwesomeString forState:UIControlStateNormal];
    [editBtn setTintColor:color];
    [editBtn setTitleColor:color forState:UIControlStateNormal];
    [editBtn.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:33.0]];
    
    return editBtn;
}

-(UIButton*) navButtonWithSelector:(SEL)selector title:(NSString*)fontAwesomeString color:(UIColor*)color
{
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [editBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [editBtn setTintColor:color];
    [editBtn setTitleColor:color forState:UIControlStateNormal];
    [editBtn setTitle:fontAwesomeString forState:UIControlStateNormal];
    [editBtn.titleLabel setFont:[UIFont fontWithName:@"BrandonGrotesque" size:20.0]];
    return editBtn;
}


-(void) zoomRect
{
    MKMapRect zoomRect = MKMapRectNull;
    
    double minimumZoom = 6000; // for my purposes the width/height have same min zoom
    BOOL needChange = NO;
    
    double x = MKMapRectGetMinX(zoomRect);
    double y = MKMapRectGetMinY(zoomRect);
    double w = MKMapRectGetWidth(zoomRect);
    double h = MKMapRectGetHeight(zoomRect);
    double centerX = MKMapRectGetMidX(zoomRect);
    double centerY = MKMapRectGetMidY(zoomRect);
    
    if (h < minimumZoom) {  // no need to call MKMapRectGetHeight again; we just got its value!
        // get the multiplicative factor used to scale old height to new,
        // then apply it to the old width to get a proportionate new width
        double factor = minimumZoom / h;
        h = minimumZoom;
        w *= factor;
        x = centerX - w/2;
        y = centerY - h/2;
        needChange = YES;
    }
    
    if (w < minimumZoom) {
        // since we've already adjusted the width, there's a chance this
        // won't even need to execute
        double factor = minimumZoom / w;
        w = minimumZoom;
        h *= factor;
        x = centerX - w/2;
        y = centerY - h/2;
        needChange = YES;
    }
    
    if (needChange) {
        zoomRect = MKMapRectMake(x, y, w, h);
    }
}







-(BOOL) prefersStatusBarHidden
{
    return YES;
}

@end

//
//  SDLocationManager.m
//  crazylikeme
//
//  Created by Seth on 4/17/14.
//  Copyright (c) 2014 Seth Arnott All rights reserved.
//

#import "SDLocationManager.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "SDLocation.h"


//#define RADIUS_IN_METERS        800
#define RADIUS_IN_MILES         1.5
#define EARTH_RADIUS_KM         6378.1
#define EARTH_RADIUS_MI         3960.0


@interface SDLocationManager()<CLLocationManagerDelegate>
{
    BOOL updatingLocation;
    BOOL performingRevGeocoding;
    NSError *lastLocationError;
    CLGeocoder *geoCoder;
    CLPlacemark *placemark;
    NSError *lastGeocoderError;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, strong) NSString *locationString;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@end

@implementation SDLocationManager
@synthesize locationManager,
            location,
            latitude,
            longitude,
            locationString,
            city,
            state,
            country
;


-(id)init
{
    if (self = [super init])
    {
        // setup location manager
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        // set initial lat/long values
        self.longitude = 0.0;
        self.latitude = 0.0;
    }
    return self;
}

-(void)getCurrentLocation
{
    // check if location services is enabled
    if (![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"Location services off");
        [self handleLocationError:[NSError errorWithDomain:@"com.sdlocation.servicesoff"
                                                      code:0311
                                                  userInfo:@{}]
                        withTitle:@"Location Services Off"
                          message:@"Location services is turned off. Open the settings app and enable location services for this app"];
        return;
    }
    
    // try to get authorization to use the device gps
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // clear any previous location attempt data
    if (location)
    {
        location = nil;
    }
    
    // set this class up to receive location updates
    locationManager.delegate = self;
    
    // set progress/status tracking ivar
    updatingLocation = YES;
    
    // tell location manager to start sending us location updates
    [self.locationManager startUpdatingLocation];
    
}

-(void)stopUpdatingLocationWithSuccess:(BOOL)success
{
    if (updatingLocation)
    {
        [self.locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        updatingLocation = NO;
    }
}


//-------------------------------------------------------------------------------
//                              Location Delegate Methods
//-------------------------------------------------------------------------------


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    // bail if needed
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0 || newLocation.horizontalAccuracy < 0)
        return;

    // update our current location
    if (self.location == nil || self.location.horizontalAccuracy > newLocation.horizontalAccuracy)
    {
        // set location if it's more accurate
        self.location = newLocation;
        
        // if our location check is accurate enough then use it
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy)
        {
            // stop receiving location updates
            [self stopUpdatingLocationWithSuccess:YES];
            
            // get our placemark data from our location
            if (!performingRevGeocoding)
            {
                performingRevGeocoding = YES;
                geoCoder = [[CLGeocoder alloc]init];
                
                [geoCoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error)
                    {
                        // set error if there is one
                        lastGeocoderError = error;
                        
                        // set our placemark or nil
                        placemark = (!error && [placemarks count] > 0) ? [placemarks lastObject] : nil;
                        
                        // update tracking ivars
                        performingRevGeocoding = NO;
                        
                        // finish
                        [self finishLocationProcessing];
                    }];
            }
        }
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Finder failed with error: %@", error.userInfo);
    
    // set our error ivar
    lastLocationError = error;
    
    // since it failed stop all updates
    [self stopUpdatingLocationWithSuccess:NO];
    
    // create a status object to report
    SDLocationStatus *status = [[SDLocationStatus alloc] init];
    status.error = error;
    status.title = @"Location Error";
    
    // determine the error message
    switch (error.code)
    {
        case kCLErrorLocationUnknown:
        {
            // unknown error occured
            status.message = @"An unknown error occured.";
            
            return;
            break;
        }
        case kCLErrorDenied:  // Access to location or ranging has been denied by the user
        {
            // show alert to have user enable location services from settings
            status.message = @"Access to location services has been denied. Open the settings app and scroll down till you find this app, then tap and enable location services.";

            break;
        }
        case kCLErrorNetwork:
        {
            // unable to determine location due to network
            status.message = @"A network error occured. Connect to a better network and retry, or choose your location using the manual option";
            break;
        }
    }
    
    // update any objects that are interested
    [self notifyLocationStatusUpdate:status];
}


-(void)finishLocationProcessing
{
    NSLog(@"Finalizing location processing");
    
    if (location)
    {
        // if randomized gps location is desired, randomize here
        
        // set latitude/longitude ivars
        self.latitude  = location.coordinate.latitude;
        self.longitude = location.coordinate.longitude;
        
        // create status object for update
        SDLocationStatus *status = [[SDLocationStatus alloc] init];
        status.latitude = self.latitude;
        status.longitude = self.longitude;
        
        if (placemark)
        {
            NSString *btnStr = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
            self.locationString = [NSString stringWithFormat:@"%@ - %@", btnStr, placemark.country];
            
            status.address   = [NSString stringWithFormat:@"%@ %@ %@", placemark.name, placemark.thoroughfare, placemark.subThoroughfare];
            status.cityState = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
            status.country   = placemark.country;
        }
        
        [self notifyLocationStatusUpdate:status];
    }
}


-(void) handleLocationError:(NSError*)error withTitle:(NSString*)title message:(NSString*)message
{
    // create status object
    SDLocationStatus *status = [[SDLocationStatus alloc] init];
    status.error = error;
    status.title = title;
    status.message = message;
    
    // fire notification
    [self notifyLocationStatusUpdate:status];
}

-(void) notifyLocationStatusUpdate:(SDLocationStatus*)status
{
    [status post];
}


@end

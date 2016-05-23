//
//  ViewModelPhotoFeed.m
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import "ViewModelPhotoFeed.h"

// api client
#import "SDFlickrClient.h"

// response
#import "SDFlickrPhotosResponse.h"

// data
#import "SDFlickrResultData.h"

// location
#import "SDLocationManager.h"
#import "MapSelectionViewController.h"

@interface ViewModelPhotoFeed()

@property (nonatomic, strong) SDFlickrClient *apiClient;


// location
@property (nonatomic, strong) SDLocationManager *locationMgr;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSString *location;


@end


@implementation ViewModelPhotoFeed


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype) init
{
    if (self = [super init])
    {
        
        
        // setup client for api calls
        self.apiClient = [[SDFlickrClient alloc] init];
    }
    return self;
}


-(void) doFetchFeedWithPage:(NSNumber *)pageNumber completion:(BlockFeedFetchCompletion)completion
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    ViewModelPhotoFeed *__weak weakself = self;
    [self.apiClient fetchRecentWithPage:pageNumber completion:^(SDFlickrPhotosResponse *response) {
        [weakself handleApiResponse:response withCompletion:completion];
    }];
    
}

-(void) doFetchFeedForSearchTerm:(NSString *)searchTerm page:(NSNumber*)page completion:(BlockFeedFetchCompletion)completion
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    ViewModelPhotoFeed *__weak weakself = self;
    
    // call Flickr client, convert json response into object useable by VC
    [self.apiClient runSearchRequestWithTerm:searchTerm page:page completion:^(SDFlickrPhotosResponse *response) {
        [weakself handleApiResponse:response withCompletion:completion];
    }];
}

-(void) doFetchFeedWithPage:(NSNumber*)pageNumber radius:(NSNumber*)radius completion:(BlockFeedFetchCompletion)completion
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    ViewModelPhotoFeed *__weak weakself = self;
    [self.apiClient runSearchRequestWithPage:pageNumber latitude:self.latitude longitude:self.longitude radius:radius completion:^(SDFlickrPhotosResponse *response) {
        [weakself handleApiResponse:response withCompletion:completion];
    }];
}


-(void) handleApiResponse:(SDFlickrPhotosResponse*)response withCompletion:(BlockFeedFetchCompletion)completion
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    if (response.error)
    {
        // TODO: handle error
        if (completion)
        {
            // pass error back to view controller
            completion(nil, response.error);
        }
        
        return;
    }
    
    if ([response.stat isEqualToString:@"ok"] && response.photo.count > 0)
    {
        if (completion)
        {
            // we have photos so return to the view controller
            completion(response.photo, nil);
        }
    }
}

-(void) fetchBuddyIconWithData:(SDFlickrResultData *)data completion:(void(^)(UIImage *image, NSError *error))completion
{
    /*
        http://farm{icon-farm}.staticflickr.com/{icon-server}/buddyicons/{nsid}.jpg
     */
    
    NSString *path = @"https://www.flickr.com/images/buddyicon.gif";
    
    if (data.iconserver.integerValue > 0)
    {
        path = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/buddyicons/%@.jpg", data.iconfarm, data.iconserver, data.owner];
    }
    
    
    [self.apiClient loadPhotoWithPath:path completion:completion];
}

-(void) fetchImageWithData:(SDFlickrResultData*)data completion:(void(^)(UIImage *image, NSError *error))completion
{
    NSString *path = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", data.farm, data.server, data.id, data.secret];
    
    [self.apiClient loadPhotoWithPath:path completion:completion];
}



#pragma mark - Direct Location Selection -

-(void) doResolveMyLocation
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    [self.locationMgr getCurrentLocation];
}

-(void) _notifLocationDidResolve:(NSNotification*)notif
{
    SDLocationStatus *status = notif.object;
    NSLog(@"SDAUser location did resolve: [%@]", status);
    
    if (status && !status.error)
    {
        self.latitude  = @(status.latitude);
        self.longitude = @(status.longitude);
        self.location  = status.cityState;
        
        // handle view controller needs on location resolve
        if (self.onLocationResolve)
        {
            self.onLocationResolve();
        }
    }
    else
    {
        NSLog(@"Status nil or status error: %@", status.error);
        // TODO: show alert for error
    }
}

-(SDLocationManager*) locationMgr
{
    // lazy load location manager
    if (! _locationMgr)
    {
        // add listener for location changes when gps updates
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_notifLocationDidResolve:) name:kLocationStatusDidChangeNotification object:nil];
        
        _locationMgr = [[SDLocationManager alloc] init];
    }
    
    return _locationMgr;
}


#pragma mark - Location Map Selection -

-(void) doSelectLocationFromMapWithParentVC:(UIViewController *)parentVC
{
    ViewModelPhotoFeed *__weak weakself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^
       {
           UIStoryboard *storyboard          = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
           MapSelectionViewController *vc    = [storyboard instantiateViewControllerWithIdentifier:@"MapSelectVC"];
           vc.mapSelectCompletion = ^(NSNumber *latitude, NSNumber *longitude, NSString *location){
               NSLog(@"Selected Lat: [%@] Long: [%@] Location: [%@]", latitude, longitude, location);
               
               // populate local properties
               weakself.latitude  = latitude;
               weakself.longitude = longitude;
               weakself.location  = location;
               
               if (weakself.onLocationResolve)
               {
                   weakself.onLocationResolve();
               }
               
               // kick off search request here with location settings
               
               [parentVC dismissViewControllerAnimated:YES completion:nil];
           };
           
           [parentVC presentViewController:vc animated:YES completion:nil];
       });
}




@end

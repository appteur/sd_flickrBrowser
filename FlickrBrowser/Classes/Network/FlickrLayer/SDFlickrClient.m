//
//  SDFlickrClient.m
//  FlickrBrowser
//
//  Created by Seth on 4/27/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import "SDFlickrClient.h"

// network
#import "SDApiClient.h"
#import "SDNetworkConfig.h"

// response
#import "SDFlickrPhotosResponse.h"

@implementation SDFlickrClient

-(void) fetchRecentWithPage:(NSNumber*)page completion:(BlockPhotoFetchCompletion)completion
{
    // set request parameters
    NSMutableDictionary *params = [self defaultParametersWithMethod:@"flickr.photos.getRecent"];
    
    if (page)
    {
        [params setObject:[page stringValue] forKey:@"page"];
    }
    
    [self runRequestWithParameters:params completion:completion];
}

-(void) runSearchRequestWithTerm:(NSString *)searchTerm page:(NSNumber*)page completion:(BlockPhotoFetchCompletion)completion
{
    // set request parameters
    NSMutableDictionary *params = [self defaultParametersWithMethod:@"flickr.photos.search"];
    
    if (page)
    {
        [params setObject:[page stringValue] forKey:@"page"];
    }
    
    if (searchTerm)
    {
        [params setObject:searchTerm forKey:@"text"];
    }
    
    [self runRequestWithParameters:params completion:completion];
}

-(void) runSearchRequestWithPage:(NSNumber *)pageNumber latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude radius:(NSNumber*)radius completion:(BlockPhotoFetchCompletion)completion
{
    NSMutableDictionary *params = [self defaultParametersWithMethod:@"flickr.photos.search"];
    
    // default to lat/long for Los Angeles if none provided with radius of 50km
    radius      = radius    ?: @(50);
    latitude    = latitude  ?: @(34.0522);
    longitude   = longitude ?: @(-118.2437);
    
    // get timestamp for 'NOW'
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    
    // rewind 12 hours
    timestamp -= (60 * 60 * 12);
    
    // set location parameters for search
    [params setObject:@"16" forKey:@"accuracy"];
    [params setObject:radius forKey:@"radius"];
    [params setObject:latitude forKey:@"lat"];
    [params setObject:longitude forKey:@"long"];
    [params setObject:@(timestamp) forKey:@"min_upload_date"];
    
    [self runRequestWithParameters:params completion:completion];
}


-(NSMutableDictionary*) defaultParametersWithMethod:(NSString*)method
{
    NSMutableDictionary *params = [@{
                                     @"api_key" : [SDNetworkConfig key_api] ?: @"",
                                     @"per_page" : @"100",
                                     @"format" : @"json",
                                     @"nojsoncallback" : @"1",
                                     @"extras" : @"owner_name,date_taken,icon_server,date_upload"
                                     } mutableCopy];
    if (method)
    {
        [params setObject:method forKey:@"method"];
    }
    
    return params;
}

-(void) runRequestWithParameters:(NSDictionary*)params completion:(BlockPhotoFetchCompletion)completion
{
    // create request object
    SDApiRequest *request = [[SDApiRequest alloc] initWithEndpoint:[SDNetworkConfig relative_path]
                                                        postParams:params
                                                           success:^(NSDictionary *response)
                                                        {
                                                            SDFlickrPhotosResponse *customResponse = [SDFlickrPhotosResponse responseFromDataDictionary:response];
                                                            
                                                            if (completion)
                                                            {
                                                                completion(customResponse);
                                                            }
                                                        }
                                                              fail:^(NSError *error)
                                                        {
                                                            SDFlickrPhotosResponse *emptyResponse = [[SDFlickrPhotosResponse alloc] init];
                                                            emptyResponse.error = error;
                                                            
                                                            if (completion)
                                                            {
                                                                completion(emptyResponse);
                                                            }
                                                           }];
    
    // fire request
    [[SDApiClient singleton] runRequest:request];
}


-(void) loadPhotoWithPath:(NSString *)path completion:(void (^)(UIImage *image, NSError *error))completion
{
    [[SDApiClient singleton] loadImageWithUrlPath:path
                                          success:^(id myResults) {
                                              
                                              UIImage *image = [[UIImage alloc] initWithData:myResults];
                                              
                                              if (completion)
                                              {
                                                  completion(image, nil);
                                              }
                                              
                                          } failure:^(NSError *error) {
                                              if (completion)
                                              {
                                                  completion(nil, error);
                                              }
                                          }];
}


@end

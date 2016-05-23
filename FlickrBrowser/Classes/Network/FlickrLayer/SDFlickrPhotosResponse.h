//
//  SDFlickrPhotosResponse.h
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDFlickrPhotosResponse : NSObject

/*
    Class Initializers
 */
+(instancetype) responseFromDataDictionary:(NSDictionary*)dataDict;
-(instancetype) initWithResponseDictionary:(NSDictionary*)responseDict;

/*
    Flattened response object encapsulating the json response returned from a search request to the flickr api.
 */
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSNumber *pages;
@property (nonatomic, strong) NSNumber *perPage;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSArray  *photo;

/*
    Request status from the flickr api. usually 'ok' or 'fail'
 */
@property (nonatomic, strong) NSString *stat;

/*
    If a network error occurs this will be set. (e.g. request timed out)
 */
@property (nonatomic, strong) NSError *error;

@end

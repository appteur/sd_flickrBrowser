//
//  SDFlickrClient.h
//  FlickrBrowser
//
//  Created by Seth on 4/27/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SDFlickrPhotosResponse;

// Completion block type definition for requests sent to the flickr api
typedef void (^BlockPhotoFetchCompletion)(SDFlickrPhotosResponse *response);


@interface SDFlickrClient : NSObject

/*
    Called by ViewModel classes to fetch the most recent posts by users.
 */
-(void) fetchRecentWithPage:(NSNumber*)page
                 completion:(BlockPhotoFetchCompletion)completion;

/*
    Called by ViewModel classes to fetch results based on a search term entered by the user.
 */
-(void) runSearchRequestWithTerm:(NSString*)searchTerm
                            page:(NSNumber*)page
                      completion:(BlockPhotoFetchCompletion)completion;

/*
    Called by ViewModel classes to fetch results based around a users location.
 */
-(void) runSearchRequestWithPage:(NSNumber *)pageNumber
                        latitude:(NSNumber*)latitude
                       longitude:(NSNumber*)longitude
                          radius:(NSNumber*)radius
                      completion:(BlockPhotoFetchCompletion)completion;

/*
    Called to load an image with a given path. If the image exists it is returned, else nil is returned.
 */
-(void) loadPhotoWithPath:(NSString*)path completion:(void(^)(UIImage *image, NSError *error))completion;

@end

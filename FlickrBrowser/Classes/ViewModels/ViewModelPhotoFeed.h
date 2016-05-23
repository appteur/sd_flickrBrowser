//
//  ViewModelPhotoFeed.h
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^BlockFeedFetchCompletion)(NSArray *results, NSError *error);

@class SDFlickrResultData;
@interface ViewModelPhotoFeed : NSObject

/*
    Block to run when a user selects location search, and their location is resolved
 */
@property (nonatomic, copy) void (^onLocationResolve)(void);

-(void) doFetchFeedWithPage:(NSNumber*)pageNumber completion:(BlockFeedFetchCompletion)completion;
-(void) doFetchFeedForSearchTerm:(NSString *)searchTerm page:(NSNumber*)page completion:(BlockFeedFetchCompletion)completion;
-(void) doFetchFeedWithPage:(NSNumber*)pageNumber radius:(NSNumber*)radius completion:(BlockFeedFetchCompletion)completion;

-(void) fetchBuddyIconWithData:(SDFlickrResultData*)data completion:(void(^)(UIImage *image, NSError *error))completion;
-(void) fetchImageWithData:(SDFlickrResultData*)data completion:(void(^)(UIImage *image, NSError *error))completion;

-(void) doResolveMyLocation;
-(void) doSelectLocationFromMapWithParentVC:(UIViewController *)parentVC;

@end

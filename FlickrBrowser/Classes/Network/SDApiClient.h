//
//  SDApiClient.h
//  memoryprank
//
//  Created by Seth Arnott on 7/24/15.
//  Copyright (c) 2015 arnottindustriesinc. All rights reserved.
//

#import "AFHTTPSessionManager.h"

// requests
#import "SDApiRequest.h"

@interface SDApiClient : AFHTTPSessionManager

+ (SDApiClient *)singleton;

-(void) runRequest:(SDApiRequest*)request;


-(void) loadImageWithUrlPath:(NSString*)path
                     success:(void(^)(id myResults))success
                     failure:(void(^)(NSError *error))failure;

// loads images from users/uploads to specified path
-(void) preloadUserImageFromRelativePath:(NSString*)urlString
                             toLocalPath:(NSString*)localPath;

-(void) downloadFileFromUrlPath:(NSString*)urlString
                     toLocation:(NSURL *)localUrl
                     completion:(void (^)(NSURL *filepath, BOOL success))completion;
@end

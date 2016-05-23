//
//  SDNetworkConfig.h
//  FlickrBrowser
//
//  Created by Seth on 4/27/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDNetworkConfig : NSObject

// api base url
+(NSString*) host_api;

// api services request relative path
+(NSString*) relative_path;

// keys
+(NSString*) key_api;

@end

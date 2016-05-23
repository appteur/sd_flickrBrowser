//
//  SDNetworkConfig.m
//  FlickrBrowser
//
//  Created by Seth on 4/27/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import "SDNetworkConfig.h"

@implementation SDNetworkConfig

+(NSString*) key_api
{
    return @"<YOUR API KEY GOES HERE>";
}

+(NSString*) host_api
{
    return @"https://api.flickr.com";
}

+(NSString*) endpoint_services
{
    return @"/services";
}

+(NSString*) request_format_rest
{
    return @"/rest/";
}

+(NSString*) relative_path
{
    NSString *path = [NSString stringWithFormat:@"%@%@", [self endpoint_services], [self request_format_rest]];
    return path;
}

@end

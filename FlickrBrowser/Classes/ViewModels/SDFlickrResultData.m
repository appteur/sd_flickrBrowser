//
//  SDFlickrResultData.m
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import "SDFlickrResultData.h"

// categories
#import "NSObject+Extensions.h"

// date
#import "SDDate.h"

@implementation SDFlickrResultData

+(instancetype) objectFromData:(NSDictionary *)data
{
    return [[self alloc] initWithResultData:data];
}

-(instancetype) initWithResultData:(NSDictionary *)data
{
    if (self != [super init])
    {
        return nil;
    }
    
    if (! (data) && data.count > 0)
    {
        return nil;
    }
    
    // populate our object properties
    [self loadPropertiesFromDictionary:data];

    // set string to display for posted date
    if (self.dateupload)
    {
        NSDate *uploaded = [NSDate dateWithTimeIntervalSince1970:self.dateupload.longLongValue];
        if (uploaded)
        {
            self.dateString = [[SDDate singleton] stringForNSDate:uploaded];
        }
    }
    
    return self;
}

@end

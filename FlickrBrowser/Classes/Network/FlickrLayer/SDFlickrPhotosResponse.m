//
//  SDFlickrPhotosResponse.m
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import "SDFlickrPhotosResponse.h"

// categories
#import "NSObject+Extensions.h"

// data objects
#import "SDFlickrResultData.h"

@implementation SDFlickrPhotosResponse

+(instancetype) responseFromDataDictionary:(NSDictionary *)dataDict
{
    return [[self alloc] initWithResponseDictionary:dataDict];
}

-(instancetype) initWithResponseDictionary:(NSDictionary *)responseDict
{
    if (self != [super init])
    {
        return nil;
    }
    
    // check if response was successful
    if ([responseDict[@"stat"] isKindOfClass:[NSString class]] && [responseDict[@"stat"] isEqualToString:@"fail"])
    {
        // there was a request error, handle and bail
        NSLog(@"Response error: %@", responseDict);
        
        // TODO: load error data here
        
        return self;
    }

    // set stat, at this point should be 'ok'
    self.stat = responseDict[@"stat"];
    
    
    // load properties from dictionary
    if (! responseDict[@"photos"])
    {
        // no photos to process, log and bail
        NSLog(@"No photos received to process: %@", responseDict);
        return self;
    }
    
    // Everything should be good now, load our responses
    NSDictionary *photoResults = responseDict[@"photos"];
    
    [self loadPropertiesFromDictionary:photoResults];
    
    return self;
}


-(void) setPhoto:(NSArray *)photo
{
    // validate our photo variable
    if ([photo isKindOfClass:[NSArray class]] && photo.count > 0)
    {
        // we have an array with dictionary results, so convert dictionaries to our data objects
        NSMutableArray *convertedResults = [NSMutableArray array];
        
        [photo enumerateObjectsUsingBlock:^(NSDictionary *resultData, NSUInteger idx, BOOL * _Nonnull stop)
        {
            // try to instantiate a data object representation of the data
            SDFlickrResultData *dataObj = [SDFlickrResultData objectFromData:resultData];
            
            if (dataObj)
            {
                // object creation succeeded, add to our array of objects
                [convertedResults addObject:dataObj];
            }
        }];
        
        _photo = convertedResults;
        return;
    }
    
    // default assignment
    _photo = photo;
}


@end

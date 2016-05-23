//
//  SDApiRequest.m
//  cosconnect
//
//  Created by Seth on 4/5/16.
//  Copyright © 2016 Seth Arnott. All rights reserved.
//

#import "SDApiRequest.h"

//#import "KeychainWrapper.h"

@interface SDApiRequest()

@end

@implementation SDApiRequest

-(instancetype) init
{
    if (self = [super init])
    {
        self.failCount = 0;
    }
    return self;
}

-(instancetype) initWithEndpoint:(NSString*)endpoint postParams:(NSDictionary*)params success:(void(^)(id response))success fail:(void(^)(NSError *error))fail
{
    if (self = [self init])
    {
        self.endpoint       = endpoint;
        self.postParams     = params;
        self.onSuccessBlock = success;
        self.onFailBlock    = fail;
    }
    return self;
}







@end

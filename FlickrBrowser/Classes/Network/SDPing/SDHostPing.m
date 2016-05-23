//
//  SDHostPing.m
//
//
//  Created by Seth on 2/6/15.
//  Copyright (c) 2015 Seth Arnott All rights reserved.
//

#import "SDHostPing.h"

// network config
#import "SDNetworkConfig.h"

@interface SDHostPing()

@property (nonatomic, weak)   id<SDHostPingDelegate>delegate;
@property (nonatomic, strong) NSOperationQueue *requestHandlerQueue;

@end


@implementation SDHostPing


-(instancetype) initWithDelegate:(id<SDHostPingDelegate>)delegate
{
    if (self = [super init])
    {
        self.delegate            = delegate;
        self.requestHandlerQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}


-(void) begin
{
    [self startPing];
}


-(void) startPing
{
    // NSURLSessionDataTask is asynchronous and runs in the background
    SDHostPing *__weak weakself = self;
    
    // get our webhost and url for the ping
    NSString *host = @"http://www.flickr.com";
    
    NSLog(@"Starting ping of --: %@", host);
    
    // setup our ping request
    NSURL *url = [NSURL URLWithString:host];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                              timeoutInterval:6.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *pingTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error)
        {
            NSLog(@"Ping of webhost successful with data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            [weakself.delegate ping:weakself didCompleteWithStatus:YES];
            return;
        }
        
        NSLog(@"Ping of webhost failed...");
        [weakself.delegate ping:weakself didCompleteWithStatus:NO];
    }];
    
    [pingTask resume];

}


@end

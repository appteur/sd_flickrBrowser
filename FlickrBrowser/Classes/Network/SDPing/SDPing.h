//
//  SDPing.h
//
//
//  Created by Seth on 2/6/15.
//  Copyright (c) 2015 Seth Arnott All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

typedef void (^PingCompletion)(BOOL success);


@class SDPing;
@protocol SDPingDelegate <NSObject>

-(void) ping:(SDPing*)pinger didCompleteWithStatus:(BOOL)status;

@end



@interface SDPing : NSObject<SimplePingDelegate>

// initialization methods
+(void) pingHost:(NSString*)hostIp completion:(PingCompletion)completion;
-(id) initWithHost:(NSString*)hostIp delegate:(id<SDPingDelegate>)delegate;

// terminate with predjudice
-(void) cancel;

@end

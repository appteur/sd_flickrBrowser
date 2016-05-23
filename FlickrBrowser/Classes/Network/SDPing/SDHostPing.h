//
//  SDHostPing.h
//
//
//  Created by Seth on 2/6/15.
//  Copyright (c) 2015 Seth Arnott All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDHostPing;
@protocol SDHostPingDelegate <NSObject>

-(void) ping:(SDHostPing*)ping didCompleteWithStatus:(BOOL)status;

@end

@interface SDHostPing : NSObject

-(instancetype) initWithDelegate:(id<SDHostPingDelegate>)delegate;
-(void) begin;

@end

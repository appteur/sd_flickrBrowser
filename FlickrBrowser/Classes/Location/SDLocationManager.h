//
//  SDLocationManager.h
//  crazylikeme
//
//  Created by Seth on 4/17/14.
//  Copyright (c) 2014 Seth Arnott All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SDLocationStatus.h"



@interface SDLocationManager : NSObject

-(void)getCurrentLocation;
-(void)stopUpdatingLocationWithSuccess:(BOOL)success;

@end

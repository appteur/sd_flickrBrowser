//
//  SDLocation.h
//  crazylikeme
//
//  Created by Seth on 3/18/14.
//  Copyright (c) 2014 Seth Arnott All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDLocation.h"
#import <UIKit/UIKit.h>

static inline double
rad2Deg(double radians)
{
    double degrees = radians*(180.0/M_PI);
    return degrees;
}

static inline double
deg2Rad(double degrees)
{
    double radians = degrees*(M_PI/180.0);
    return radians;
}


struct SDLocation {
    CGFloat longitude;
    CGFloat latitude;
};
typedef struct SDLocation SDLocation;


struct SDGeoFence{
    SDLocation northwest;
    SDLocation southeast;
};
typedef struct SDGeoFence SDGeoFence;



/*
    Take a random lat/long of 34.773040 N / -115.961827 W.
    If you want the upper left box corner at 5miles N & W you take the point and add the radius(mi as degrees)
    to get a higher number (farther west, farther north is higher #). To get the southeast corner you need a lower
    number in both cases (lat/long # decreases as you go south/east).
*/


//function takes radius in degrees
static inline SDGeoFence
SDGeoFenceMake(SDLocation myLoc, double radius, BOOL metric)
{
    int earthRadius = metric ? 6371 : 3959;
    
    float latRadian = deg2Rad(myLoc.latitude);
    float longRadian = deg2Rad(myLoc.longitude);
    double bearingNW = deg2Rad(315);
    double bearingSE = deg2Rad(135);
    float distance = (radius/sin(deg2Rad(45.0))); //radius is distance n/s/e/w, we need the distance to the points where the lat/long converge
    double nwLat  = rad2Deg(asin(sin(latRadian) * cos(distance/earthRadius) + cos(latRadian) * sin(distance/earthRadius) * cos(bearingNW)));
    double seLat  = rad2Deg(asin(sin(latRadian) * cos(distance/earthRadius) + cos(latRadian) * sin(distance/earthRadius) * cos(bearingSE)));
    double nwLong = rad2Deg(longRadian + atan2(sin(bearingNW) * sin(distance/earthRadius) * cos(latRadian), cos(distance/earthRadius) - sin(latRadian) * sin(nwLat)));
    double seLong = rad2Deg(longRadian + atan2(sin(bearingSE) * sin(distance/earthRadius) * cos(latRadian), cos(distance/earthRadius) - sin(latRadian) * sin(seLat)));
    
    SDGeoFence fence;
    fence.northwest.longitude = nwLong; //0 @ Greenwich. + thru US to Dateline -thru Europe/Russia
    fence.northwest.latitude  = nwLat; //0 @ equator. + towards N pole, - towards S pole
    fence.southeast.longitude = seLong;
    fence.southeast.latitude  = seLat;
    return fence;
}


static inline SDLocation
SDLocationMake(CGFloat latitude, CGFloat longitude)
{
    SDLocation location;
    location.longitude = longitude;
    location.latitude  = latitude;
    return location;
}

static inline NSString*
NSStringFromSDGeoFence(SDGeoFence fence)
{
    NSString *string = [NSString stringWithFormat:@"{{%f,%f},{%f,%f}}", fence.northwest.latitude, fence.northwest.longitude, fence.southeast.latitude, fence.southeast.longitude];
    return string;
}




//@interface SDLocationClass : NSObject
//
//@end
//
//@implementation SDLocationClass
//
//-(void)generatePointsAroundLocation:(SDLocation)point
//{
//    //this gives me two points top left and bottom right. If the second pair of numbers were width and height
//    //the width would be simply(fiveMiInDeg *2) and height simply (fiveMiInDeg*2)
//    
//    SDGeoFence fiveMiFence    = SDGeoFenceMake(point, 5, NO);
//    SDGeoFence tenMiFence     = SDGeoFenceMake(point, 10, NO);
//    SDGeoFence twentyMiFence  = SDGeoFenceMake(point, 20, NO);
//    SDGeoFence fiftyMiFence   = SDGeoFenceMake(point, 50, NO);
//    SDGeoFence oneHunMiFence  = SDGeoFenceMake(point, 100, NO);
//    SDGeoFence twoHunMiFence  = SDGeoFenceMake(point, 200, NO);
//    SDGeoFence thrHunMiFence  = SDGeoFenceMake(point, 300, NO);
//    SDGeoFence fivHunMiFence  = SDGeoFenceMake(point, 500, NO);
//    
//    StrippedLog(@"Five: %@", NSStringFromSDGeoFence(fiveMiFence));
//    StrippedLog(@"Ten: %@", NSStringFromSDGeoFence(tenMiFence));
//    StrippedLog(@"Twenty: %@", NSStringFromSDGeoFence(twentyMiFence));
//    StrippedLog(@"Fifty: %@", NSStringFromSDGeoFence(fiftyMiFence));
//    StrippedLog(@"100: %@", NSStringFromSDGeoFence(oneHunMiFence));
//    StrippedLog(@"200: %@", NSStringFromSDGeoFence(twoHunMiFence));
//    StrippedLog(@"300: %@", NSStringFromSDGeoFence(thrHunMiFence));
//    StrippedLog(@"500: %@", NSStringFromSDGeoFence(fivHunMiFence));
//}
//
//
//@end







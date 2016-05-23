//
//  SDLocationStatus.m
//  cosconnect
//
//  Created by Seth on 3/25/16.
//  Copyright © 2016 Seth Arnott. All rights reserved.
//

#import "SDLocationStatus.h"


NSString * const kLocationStatusDidChangeNotification = @"k_location_status_did_change";

@implementation SDLocationStatus

-(void) post
{
    // fire notification with location status object
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotification *notif = [NSNotification notificationWithName:kLocationStatusDidChangeNotification
                                                              object:self];
        
        [[NSNotificationCenter defaultCenter] postNotification:notif];
    });
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"LAT: [%f], LONG: [%f], Address: [%@], CityState: [%@], Country: [%@]", self.latitude, self.longitude, self.address, self.cityState, self.country];
}

@end

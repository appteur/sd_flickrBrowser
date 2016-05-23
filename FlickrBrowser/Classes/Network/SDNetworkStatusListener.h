//
//  SDNetworkStatusListener.h
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDNetworkStatusListener : NSObject

/*
    If you want to be updated when the network connection changes you can listen to this property via KVO and
        update when this changes T/F.
 */
@property (nonatomic, assign) BOOL isConnected;

/*
    Call this method to ping the api host defined in the network config file to verify that the network connection is available.
 */
-(void) verifyHostAvailability;

// connection type as string for analytics
// will be (none, wifi, cellular)
-(NSString*) connectionType;


@end

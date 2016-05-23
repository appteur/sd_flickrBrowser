//
//  SDNetworkStatusListener.m
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import "SDNetworkStatusListener.h"

#import "Reachability.h"

// ping
#import "SDHostPing.h"

// network notification
#import "SDNetworkNotificationDefines.h"

#define kMAX_PING_ATTEMPTS  4



@interface SDNetworkStatusListener()<SDHostPingDelegate>

@property (nonatomic, strong) Reachability *networkReachable;
@property (nonatomic, strong) Reachability *hostReachable;

@property (nonatomic, assign) NetworkStatus netStatus;
@property (nonatomic, assign) NetworkStatus hostStatus;

@property (nonatomic, assign) BOOL netActive;
@property (nonatomic, assign) BOOL hostActive;

@property (nonatomic, assign) BOOL previouslyActiveConnection;
@property (nonatomic, assign) BOOL pingableNetwork;
@property (nonatomic, assign) BOOL pingInProgress;
@property (nonatomic, assign) NSUInteger pingAttempts;

@property (nonatomic, strong) SDHostPing *sitePing;

// tracks the current connection type
@property (nonatomic, strong) NSString *connectionType;

@end


@implementation SDNetworkStatusListener

-(void) dealloc
{
    NSLog(@"Dealloc: %s", __FUNCTION__);
    
    //stop notifications
    if (_hostReachable)     [self.hostReachable stopNotifier];
    if (_networkReachable)  [self.networkReachable stopNotifier];
    
    //remove self from notification center
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //nil our properties
    _hostReachable    = nil;
    _networkReachable = nil;
}

-(instancetype) init
{
    if (self = [super init])
    {
        self.pingInProgress = NO;
        self.pingAttempts = 0;
        
        // add listener for network status changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notif_reachabilityDidChange:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        // setup network reachability
        self.networkReachable = [Reachability reachabilityForInternetConnection];
        [self.networkReachable startNotifier];
        self.netStatus = [self.networkReachable currentReachabilityStatus];
        
        // setup host reachability
        self.hostReachable = [Reachability reachabilityWithHostName:@"8.8.8.8"];
        [self.hostReachable startNotifier];
        self.hostStatus = [self.hostReachable currentReachabilityStatus];
        
        
        
        [self verifyHostAvailability];
    }
    
    return self;
}


-(void) verifyHostAvailability
{
    if (! self.pingInProgress)
    {
        self.pingInProgress = YES;
        
        [self queuePing];
    }
}

-(void) queuePing
{
    // increments our counter
    self.pingAttempts += 1;
    
    // creates a new connection in self.sitePing class and tries to hit the login page
    [self.sitePing begin];
}


#pragma mark - ALSitePing Delegate Methods

-(void) ping:(SDHostPing *)ping didCompleteWithStatus:(BOOL)status
{
    if (status) // if ping was successful then status = YES
    {
        // update our connection tracker to YES
        self.pingableNetwork    = YES;
        
        // the network is accessible so update our active connection property
        [self updateActiveConnectionStatus];
        
        // ping check complete, we have a network connection
        self.pingInProgress = NO;
        
        // reset our ping counter for next try
        self.pingAttempts   = 0;
    }
    else
    {
        // determine the number of pings we've attempted already
        //        NSInteger pingAttempts = [self pingHosts].count - self.availablePings.count;
        
        if (self.pingAttempts <= kMAX_PING_ATTEMPTS)
        {
            // this ping failed, but we have more ip's we can ping, try the next one
            [self queuePing];
        }
        else   // we have exhausted our available pings so it's likely that we have no network connection
        {
            // all pings failed so mark our tracker NO
            self.pingableNetwork = NO;
            
            // we can't reach the network so update our active connection property
            [self updateActiveConnectionStatus];
            
            // ping check complete, we have no ping successes
            self.pingInProgress = NO;
            
            // reset our ping counter for next try
            self.pingAttempts  = 0;
        }
    }
}


// this updates our active connection property. This property is one that other objects observe via KVO so other
// objects will also be updated if this changes
-(void) updateActiveConnectionStatus
{
    // reachability says our connection is good and we confirmed with a ping of our host
    BOOL currentIsActiveConnection = (_netActive && _hostActive && self.pingableNetwork) ? YES : NO;
    
    // only update property if it's different than what's already set
    if(self.previouslyActiveConnection != currentIsActiveConnection)
    {
        // update this property so any listeners will be updated
        self.isConnected                = currentIsActiveConnection;
        self.previouslyActiveConnection = currentIsActiveConnection;
        
        // post notification
        [self postNetworkStatusNotification];
    }
    
}



-(void) notif_reachabilityDidChange:(NSNotification*)notif
{
    NSLog(@"%s :: Reachability status: user info: %@", __FUNCTION__, notif.userInfo);
    
    ////////////////////////////////////////////////////////////////////////
    //Check if the status has actually changed
    //This might seem redundant but sometimes we'll get several "now online"
    //notifications in a row from Reachability
    ////////////////////////////////////////////////////////////////////////
    
    
    // get our internet status
    self.netStatus  = [self.networkReachable  currentReachabilityStatus];
    self.hostStatus = [self.hostReachable     currentReachabilityStatus];
    
    // set whether internet is active or not
    self.netActive  = (_netStatus == NotReachable) ? NO : YES;
    
    // set whether our host site is available or not
    self.hostActive = (_hostStatus == NotReachable) ? NO : YES;
    
    // update our active connection property (This will trigger any objects observing via KVO)
    [self updateActiveConnectionStatus];
    
    // determine the current connection type
    _connectionType = (_netStatus == NotReachable) ? @"none" :((_netStatus == ReachableViaWiFi) ? @"wifi" : @"cellular");
    
    // post notification
    [self postNetworkStatusNotification];
    
    // reachability thinks the network status changed, verify we can still ping a network
    [self verifyHostAvailability];
}


-(void) postNetworkStatusNotification
{
    NSLog(@"Posting Network Notification. isConnected: [%@] - connectionType: [%@]", self.isConnected ? @"YES" : @"NO", self.connectionType);
    
    NSNotification *connectionNotification = [NSNotification notificationWithName:kSDNetworkConnectionDidChangeNotification
                                                                           object:nil
                                                                         userInfo:@{
                                                                                    @"isConnected" : @(self.isConnected),
                                                                                    @"type" : self.connectionType ?: @"unknown"
                                                                                    }];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:connectionNotification waitUntilDone:NO];
}


#pragma mark - Lazy Loaded Properties -
-(SDHostPing*) sitePing
{
    if (! _sitePing)
    {
        _sitePing = [[SDHostPing alloc] initWithDelegate:self];
    }
    return _sitePing;
}


@end

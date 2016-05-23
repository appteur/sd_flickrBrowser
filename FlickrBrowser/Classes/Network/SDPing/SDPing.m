//
//  SDPing.m
//
//
//  Created by Seth on 2/6/15.
//  Copyright (c) 2015 Seth Arnott All rights reserved.
//

#import "SDPing.h"

// ping imports
#include <sys/socket.h>
#include <netdb.h>


// config defines
#define PING_TIME_LIMIT 2.0f


// C methods
static NSString * DisplayAddressForAddress(NSData * address)
// Returns a dotted decimal string for the specified address (a (struct sockaddr) within the address NSData).
{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil) {
        err = getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr), NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = [NSString stringWithCString:hostStr encoding:NSASCIIStringEncoding];
            assert(result != nil);
        }
    }
    
    return result;
}




@interface SDPing()

@property (nonatomic, strong) SimplePing *pinger;

// completion/delegation
@property (nonatomic, copy) PingCompletion completion;
@property (nonatomic, weak) id<SDPingDelegate>delegate;

@end


@implementation SDPing


+(void) pingHost:(NSString *)hostIp completion:(PingCompletion)completion
{
    // SDPing is retained via the timeout 'performSelector' triggered in the begin method
    [[[SDPing alloc] initWithHost:hostIp completion:completion] begin];
}




-(id) initWithHost:(NSString*) hostIP completion:(PingCompletion)completion
{
    if (self = [super init])
    {
        self.pinger             = [SimplePing simplePingWithHostName:hostIP];
        self.pinger.delegate    = self;
        self.completion         = completion;
    }
    return self;
}

-(instancetype) initWithHost:(NSString *)hostIp delegate:(id<SDPingDelegate>)delegate
{
    if (self = [super init])
    {
        self.delegate        = delegate;
        self.pinger          = [SimplePing simplePingWithHostName:hostIp];
        self.pinger.delegate = self;
        
        [self begin];
    }
    return self;
}





#pragma mark - Ping Management Methods


-(void) begin
// starts the pinger and schedules a time limit method call
{
    [self.pinger start];
    [self performSelector:@selector(timeout) withObject:nil afterDelay:PING_TIME_LIMIT];
}

-(void) pingSuccess
// called when our ping receives a response
{
    [self cleanupPinger];
    [self completeWithStatus:YES];
}

-(void) pingFail
// called when pinger delegate fail method gets called
{
    [self cleanupPinger];
    [self completeWithStatus:NO];
}

-(void) timeout
// called when a ping exceeds the time limit, cancels the ping and sends fail message
{
    if (self.pinger)
    {
        [self cleanupPinger];
        [self completeWithStatus:NO];
    }
}

-(void) cancel
{
    // we are cancelling so prevent any callbacks
    self.delegate   = nil;
    self.completion = nil;
    
    // clean our ping object
    [self cleanupPinger];
}

-(void) cleanupPinger
// stops and nils out the pinger object
{
    if (self.pinger)
    {
        [self.pinger stop];
        self.pinger = nil;
    }
}

-(void) completeWithStatus:(BOOL)status
// calls the completion block
{
    if (self.delegate)
    {
        [self.delegate ping:self didCompleteWithStatus:status];
    }
    else if (self.completion)
    {
        self.completion(status);
    }
}






#pragma mark - Pinger Delegate Methods


- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
// A SimplePing delegate callback method.  We respond to the startup by sending a ping immediately
{
    NSLog(@"++++ Pinging Host: %@", DisplayAddressForAddress(address));
    [self.pinger sendPingWithData:nil];
}


- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
// A SimplePing delegate callback method.  We just log the reception of a ping response.
{
    NSLog(@"++++ Pinger Response: #%u received", (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber) );
    [self pingSuccess];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
// A SimplePing delegate callback method.  Log the error and call fail method
{
    NSLog(@"++++ Pinger Error: %@", [self shortErrorFromError:error]);
    [self pingFail];
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
// A SimplePing delegate callback method.  We just log the failure and call fail method.
{
    NSLog(@"++++ Pinger Error: send failed - %@", [self shortErrorFromError:error]);
    [self pingFail];
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
// A SimplePing delegate callback method.  We just log the receive.
{
    NSLog(@"++++ Pinger Response: unexpected packet received.");
}






#pragma mark - Helper methods


- (NSString *)shortErrorFromError:(NSError *)error
// Given an NSError, returns a short error string that we can print, handling
// some special cases along the way.
{
    NSString *      result;
    NSNumber *      failureNum;
    int             failure;
    const char *    failureStr;
    
    assert(error != nil);
    
    result = nil;
    
    // Handle DNS errors as a special case.
    
    if ( [[error domain] isEqual:(NSString *)kCFErrorDomainCFNetwork] && ([error code] == kCFHostErrorUnknown) )
    {
        failureNum = [[error userInfo] objectForKey:(id)kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] )
        {
            failure = [failureNum intValue];
            if (failure != 0)
            {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL)
                {
                    result = [NSString stringWithUTF8String:failureStr];
                }
            }
        }
    }
    
    // Otherwise try various properties of the error object.
    
    if (result == nil) {
        result = [error localizedFailureReason];
    }
    if (result == nil) {
        result = [error localizedDescription];
    }
    if (result == nil) {
        result = [error description];
    }
    return result;
}








@end

//
//  SDLocationStatus.h
//  cosconnect
//
//  Created by Seth on 3/25/16.
//  Copyright © 2016 Seth Arnott. All rights reserved.
//

#import <Foundation/Foundation.h>

// notification key for location status updates
FOUNDATION_EXPORT NSString * const kLocationStatusDidChangeNotification;

// encapsulation object for location status notifications
@interface SDLocationStatus : NSObject

// message alert properties if error is set
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

// location properties if error is not set
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *cityState;
@property (nonatomic, strong) NSString *country;

// call to post NSNotification with this object using notification key above
-(void) post;
@end

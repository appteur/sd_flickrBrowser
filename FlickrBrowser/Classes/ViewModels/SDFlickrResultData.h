//
//  SDFlickrResultData.h
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDFlickrResultData : NSObject

+(instancetype) objectFromData:(NSDictionary*)data;

-(instancetype) initWithResultData:(NSDictionary*)data;

@property (nonatomic, strong) NSNumber *farm;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *isfamily;
@property (nonatomic, strong) NSNumber *isfriend;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSNumber *server;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *ownername;
@property (nonatomic, strong) NSString *datetaken;
@property (nonatomic, strong) NSNumber *iconserver;
@property (nonatomic, strong) NSNumber *iconfarm;
@property (nonatomic, strong) NSNumber *dateupload;

@property (nonatomic, strong) NSString *dateString;

@end

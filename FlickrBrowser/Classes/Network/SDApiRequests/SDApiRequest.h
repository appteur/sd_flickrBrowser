//
//  SDApiRequest.h
//  cosconnect
//
//  Created by Seth on 4/5/16.
//  Copyright © 2016 Seth Arnott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDApiRequest : NSObject

@property (nonatomic, strong) NSDictionary *postParams;
@property (nonatomic, strong) NSString *endpoint;
@property (nonatomic, strong) NSString *apiPath;
@property (nonatomic, strong) NSString *responseClassName;

@property (nonatomic, assign) NSInteger failCount;
@property (nonatomic, copy) void(^onFailBlock)(NSError *error);
@property (nonatomic, copy) void(^onSuccessBlock)(id response);


-(instancetype) initWithEndpoint:(NSString*)endpoint
                      postParams:(NSDictionary*)params
                         success:(void(^)(id response))success
                            fail:(void(^)(NSError *error))fail;


@end

//
//  SDApiClient.m
//  memoryprank
//
//  Created by Seth Arnott on 7/24/15.
//  Copyright (c) 2015 arnottindustriesinc. All rights reserved.
//

// api/network
#import "SDApiClient.h"
#import "SDNetworkConfig.h"

// categories
#import "NSString+Extensions.h"
#import "NSObject+Extensions.h"

// network status listener
#import "SDNetworkStatusListener.h"

@interface SDApiClient()

@property (nonatomic, strong) SDNetworkStatusListener *netListener;

@end


//Supress compiler warnings for "PerformSelector may cause a leak because its selector is unknown"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation SDApiClient


+(NSURL*) webServiceUrl
{
    NSString *webService = [SDNetworkConfig host_api];
    return [NSURL URLWithString:webService];
}




+ (SDApiClient *)singleton
{
    static SDApiClient *_single = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
        {
            _single = [[self alloc] initWithBaseURL:[self webServiceUrl]];
        });
    
    return _single;
}


- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self)
    {
        // setup serializers
        self.requestSerializer  = [AFHTTPRequestSerializer serializer]; // AFHTTPRequestSerializer populates the POST variable on requests... AFJSONRequestSerializer
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // setup network availability monitor on main thread for notifications registered in run loop
            self.netListener = [[SDNetworkStatusListener alloc] init];
            [self.netListener verifyHostAvailability];
        });
    }
    
    return self;
}


-(void) runRequest:(SDApiRequest*)request
{
    SDApiClient *__weak weakself = self;
    
    if (request.endpoint)
    {
        [self POST: request.endpoint
        parameters:request.postParams
           success:^(NSURLSessionDataTask *task, id response)
         {
             NSLog(@"Response received from: [%@]", request.endpoint);
             // convert our response to a custom response if possible
             id customResponse = [weakself customResponseForRequest:request withData:response];
             
             if (request.onSuccessBlock)
             {
                 request.onSuccessBlock(customResponse);
             }
         }
           failure:^(NSURLSessionDataTask *task, NSError *error)
         {
             NSLog(@"Api Request Error: [%@] \nFor endpoint: [%@] \nWith Params: [%@]", error, request.apiPath, request.postParams);
             
             if (request.failCount < 3)
             {
                 NSLog(@"Retrying api request [%@]", request.endpoint);
                 
                 // increment fail count
                 request.failCount ++;
                 
                 // retry request
                 [weakself runRequest:request];
             }
             else
             {
                 // we have failed 3x, run our fail block
                 if (request.onFailBlock)
                 {
                     request.onFailBlock(error);
                 }
             }
         }];
    }
    else
    {
        NSLog(@"INVALID ENDPOINT >>> no path found for endpoint with name: [%@]", request.endpoint);
    }
}


-(id) customResponseForRequest:(SDApiRequest*)request withData:(id)responseData
{
    id customResponse;
    NSString *string             = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict       = [string jsonDictionaryRepresentation];
    
    NSLog(@"Class: [%@] RESPONSE: %@", request.responseClassName, [string jsonDictionaryRepresentation]);
    if (! jsonDict)
    {
        NSLog(@"responseString: %@", string);
    }
    
    // if we have a classname try to instantiate a response object
//    if (request.responseClassName && jsonDict)
//    {
//        @try
//        {
//            // try to create a custom response object based on the name
//            customResponse = [[NSClassFromString(request.responseClassName) alloc] init];
//            
//            // try to load our properties from the response dictionary
//            if (customResponse)
//            {
//                SEL setRequest = @selector(setRequest:);
//                if ([customResponse respondsToSelector:setRequest])
//                {
//                    [customResponse performSelector:setRequest withObject:request];
//                }
//                
//                [customResponse loadPropertiesFromDictionary:jsonDict];
//            }
//            else
//            {
//                NSLog(@"Custom response object appears to be nil, or does not respond to loadPropertiesFromDictionary: method");
//            }
//        }
//        @catch (NSException *exception)
//        {
//            NSLog(@"EXCEPTION:: %@", exception);
//        }
//    }
//    else
//    {
        // if we don't have a custom response then just return our jsonDictionary response
        customResponse = jsonDict;
//    }
    
    return customResponse;
}



-(void) loadImageWithUrlPath:(NSString*)path
                     success:(void(^)(id myResults))success
                     failure:(void(^)(NSError *error))failure
{
    [self GET:path
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if (success)
          {
              success(responseObject);
          }
    }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure)
        {
            NSLog(@"Error fetching image file with path: %@ -- %@", path, error);
            failure(error);
        }
      }];
}

-(void) preloadUserImageFromRelativePath:(NSString*)urlString toLocalPath:(NSString*)localPath
{
    NSString *webhost = [SDNetworkConfig host_api];
    NSString *relativePath = @"/users/uploads";
    NSString *remotePath = [NSString stringWithFormat:@"%@%@%@", webhost, relativePath, urlString];
    
    [self downloadFileFromUrlPath:remotePath toLocation:[NSURL fileURLWithPath:localPath] completion:nil];
}



-(void) downloadFileFromUrlPath:(NSString*)urlString toLocation:(NSURL *)localUrl completion:(void (^)(NSURL *filepath, BOOL success))completion
{
    if (! urlString)
    {
        return;
    }
    
    NSURL *URL            = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request
                                                                  progress:nil
                                                               destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                                                          {
                                                                              return localUrl;
                                                                          }
                                                         completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                                                                          {
                                                                              if (error)
                                                                              {
                                                                                  NSLog(@"ERROR DOWNLOADING IMAGE: %@", error);
                                                                              }
                                                                              
                                                                              if (completion)
                                                                              {
                                                                                  BOOL succeeded = (error == nil);
                                                                                  completion(filePath, succeeded);
                                                                              }
                                                                              
                                                                          }];
    [downloadTask resume];
}









@end

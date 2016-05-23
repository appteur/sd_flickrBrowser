//
//  NSObject+Extensions.h
//  connectionTest
//
//  Created by Seth on 10/21/14.
//  Copyright (c) 2014 MyCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (Extensions)

-(NSArray*) propertyNamesArray;


-(BOOL) isIphone;
-(BOOL) isIpad;

+(BOOL) isIphone;
+(BOOL) isIpad;

-(CGSize) screenSize;

-(void) loadPropertiesFromDictionary:(NSDictionary*)dictionary;
-(void) loadPropertiesFrom:(NSObject*)object;



@end

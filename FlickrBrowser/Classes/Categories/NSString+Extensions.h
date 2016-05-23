//
//  NSString+Extensions.h
//  connectionTest
//
//  Created by Seth on 7/11/14.
//  Copyright (c) 2014 MyCompany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)


// SHA HASHING
-(NSString*) sha1Value;
-(NSString*) sha256Value;
-(NSString*) sha512Value;


- (NSDictionary*) jsonDictionaryRepresentation;

@end

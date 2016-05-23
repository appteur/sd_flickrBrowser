//
//  DateCompare.h
//  
//
//  Created by Seth on 4/18/14.
//  Copyright (c) 2014 Seth Arnott All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDDate : NSObject

+(id) singleton;

//
-(NSString*) yearsSinceTimestampString:(NSString*)timestamp;

// returns today/yesterday/etc from formatted date string
-(NSString*)stringForDate:(NSString*)dateString;

// returns today/yesterday/etc from NSDate object
-(NSString*)stringForNSDate:(NSDate*)date;

// string - date conversion
-(NSDate*)dateFromString:(NSString*)dateString;
-(NSDate*) ymdDateFromString:(NSString*)dateString;

// returns a timestamp in string format
-(NSString*)timestampFromDate:(NSDate*)date;
-(NSString*) ymdTimestampFromDate:(NSDate*)date;

// current year as integer
-(NSUInteger) currentYear;

// sort by date
// newest first
///-(NSArray*)sortArrayByDateDescending:(NSArray*)sortee;
// oldest first
//-(NSArray*)sortArrayByDateAscending:(NSArray *)sortee;
@end

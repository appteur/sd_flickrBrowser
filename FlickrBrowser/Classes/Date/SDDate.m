//
//  DateCompare.m
//  
//
//  Created by Seth on 4/18/14.
//  Copyright (c) 2014 Seth Arnott All rights reserved.
//

#import "SDDate.h"


@interface SDDate()
@property (nonatomic, assign) float secondsPerDay;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation SDDate

@synthesize secondsPerDay
;

+(id) singleton
{
    static SDDate *_single = nil;
    static dispatch_once_t oncePred;
    dispatch_once(&oncePred, ^
                  {
                      _single = [[SDDate alloc] init];
                  });
    return _single;
}

-(id)init
{
    if (self = [super init])
    {
        self.secondsPerDay = 24 * 60 * 60;
        self.formatter = [[NSDateFormatter alloc]init];
    }
    return self;
}


-(NSString*) yearsSinceTimestampString:(NSString *)dob
{
    // calculate age based on DOB and set our profile age
    NSDate *birthday = [[SDDate singleton] ymdDateFromString:dob];
    NSDate *now = [NSDate date];
    
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    
    NSNumber *age = [NSNumber numberWithInteger:[ageComponents year]];
    
    return [age stringValue];
}


// converts date string into NSDate object
-(NSDate*)dateFromString:(NSString*)dateString
{
    [self.formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *myDate = [self.formatter dateFromString:dateString];
    return myDate;
}

-(NSDate*) ymdDateFromString:(NSString*)dateString
{
    [self.formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *myDate = [self.formatter dateFromString:dateString];
    return myDate;
}

-(NSString*)stringForNSDate:(NSDate*)date
{
    NSString *timestamp = [self timestampFromDate:date];
    NSString *formatted = [self stringForDate:timestamp];
    
    return formatted;
}

// this gets the proper string to display on messages/winks (today/yesterday/sunday/etc)
-(NSString*)stringForDate:(NSString*)dateString
{
    NSString *ret;
    NSDate *date = [self dateFromString:dateString];
//    NSString *timePassed = [self timePassedSinceDate:date];
    
    BOOL thisWeek = [self isDateWithinLastSevenDays:date];
    
    if (thisWeek)
    {
        ret = [self stringForDateSinceYesterday:date];
        if (!ret)
        {
            ret =[self weekdayStringFromDate:date];
        }
        if (!ret)
        {
            ret = @"";
        }
    }else
    {
        ret = [self dateStringForDate:date];
        if (!ret)
        {
            ret = @"";
        }
    }
    
    return ret;
}

-(NSUInteger) currentYear
{
    [self.formatter setDateFormat:@"yyyy"];
    NSString *yearString = [self.formatter stringFromDate:[NSDate date]];
    
    return [yearString integerValue];
}

// this formats month, day
-(NSString*)dateStringForDate:(NSDate*)date
{
    [self.formatter setDateFormat:@"MMM dd"];
    NSString *dateStr = [self.formatter stringFromDate:date];
    return dateStr;
}

// this makes a complete timestamp string from an NSDate object
-(NSString*)timestampFromDate:(NSDate*)date
{
    [self.formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateStr = [self.formatter stringFromDate:date];
    return dateStr;
}

-(NSString*) ymdTimestampFromDate:(NSDate*)date
{
    [self.formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [self.formatter stringFromDate:date];
    return dateStr;
}

-(NSString*)weekdayStringFromDate:(NSDate*)date
{
    // get the day of the week and the day of the month
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear) fromDate:date];
//    NSInteger day     = [weekdayComponents day];
    NSInteger weekday = [weekdayComponents weekday];
    
//    StrippedLog(@" day: %ld", (long)day);
    NSString *wDay;
    
    switch (weekday) {
        case 1: wDay = @"Sunday";    break;
        case 2: wDay = @"Monday";    break;
        case 3: wDay = @"Tuesday";   break;
        case 4: wDay = @"Wednesday"; break;
        case 5: wDay = @"Thursday";  break;
        case 6: wDay = @"Friday";    break;
        case 7: wDay = @"Saturday";  break;
    }
    return wDay;
}

// this gets the time elapsed since the date you pass it
-(NSString*)timePassedSinceDate:(NSDate*)start
{
    NSDate *now = [NSDate date];
    NSCalendar *calen = [NSCalendar currentCalendar];
//    NSDateComponents *comp = [calen components:(NSYearCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:start toDate:now options:0];
    NSDateComponents *comp = [calen components:NSCalendarUnitSecond fromDate:start toDate:now options:0];
    NSString *string = [NSString stringWithFormat:@"%ld years, %ld days, %ld hours, %ld minutes, %ld seconds",  (long)comp.year, (long)comp.day, (long)comp.hour, (long)comp.minute, (long)comp.second];
    NSLog(@"%@",  string);
    
    return string;
}

// if the date is since start of yesterday this returns today/yesterday otherwise nil
-(NSString*)stringForDateSinceYesterday:(NSDate*)date
{
    // get yesterday
    NSDate *yesterday = [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
    
    // setup calendar
    NSCalendar *calen = [NSCalendar autoupdatingCurrentCalendar];
    
    // get day range for yesterday
    NSDate         *yStart;
    NSTimeInterval yExtends;
    // get day range for today
    NSDate         *tStart;
    NSTimeInterval tExtends;
    BOOL ystrdy  = [calen rangeOfUnit:NSCalendarUnitDay startDate:&yStart interval:&yExtends forDate:yesterday];
    BOOL today   = [calen rangeOfUnit:NSCalendarUnitDay startDate:&tStart interval:&tExtends forDate:[NSDate date]];
    
    if (!ystrdy || !today) return nil;
    
    // get time for date and start time for yesterday
    NSTimeInterval dateInSecs     = [date  timeIntervalSinceReferenceDate];
    NSTimeInterval yesterdayStart = [yStart timeIntervalSinceReferenceDate];
    NSTimeInterval todayStart     = [tStart timeIntervalSinceReferenceDate];
    
    // if our date falls between start and end of yesterday return yesterday
    if (dateInSecs > yesterdayStart && dateInSecs < (yesterdayStart + yExtends))
        return @"Yesterday";
    
    // if our date is after the start of today return today
    else if (dateInSecs > todayStart)
        return @"Today";
    
    return nil;
}

// calculates if date is since midnight Saturday
-(BOOL)isDateThisWeek:(NSDate *)date
{
    NSDate          *start;
    NSTimeInterval  extends;
    NSCalendar      *cal     = [NSCalendar autoupdatingCurrentCalendar];
    NSDate          *today   = [NSDate date];
    BOOL            success  = [cal rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&start interval: &extends forDate:today];
    
    if(!success)return NO;
    
    NSTimeInterval dateInSecs       = [date timeIntervalSinceReferenceDate];
    NSTimeInterval dayStartInSecs   = [start timeIntervalSinceReferenceDate];
    
    if(dateInSecs > dayStartInSecs && dateInSecs < (dayStartInSecs+extends))
        return YES;
    else
        return NO;
}

-(BOOL)isDateWithinLastSevenDays:(NSDate*)date
{
    // determine time one week ago
    float secondsPerWeek = self.secondsPerDay * 7;
    
    // get time in seconds for date and one week ago
    NSTimeInterval oneWeekAgo = [[NSDate date] timeIntervalSinceReferenceDate] - secondsPerWeek;
    NSTimeInterval dateInSecs = [date timeIntervalSinceReferenceDate];
    
    // if date is after one week ago return yes
    if (dateInSecs > oneWeekAgo)
        return YES;
    
    return NO;
}


// sorts array of dates or array of MessageCapsules by date, most recent first
//-(NSArray*)sortArrayByDateDescending:(NSArray*)sortee
//{
//    NSSortDescriptor *descending;
//    
//    if ([sortee[0] isKindOfClass:[NSString class]])
//    {
//        descending = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO];
//        sortee = [self convertDateStringArrayToDateArray:sortee];
//    }
//    else if ([sortee[0] isKindOfClass:[MessageCapsule class]])
//    {
//        descending = [[NSSortDescriptor alloc] initWithKey:@"msgDate" ascending:NO];
//    }
//    
//    NSArray *descriptors = [NSArray arrayWithObject:descending];
//    NSArray *sorted = [sortee sortedArrayUsingDescriptors:descriptors];
//    [sorted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[MessageCapsule class]])
//            StrippedLog(@"%@ : %@", obj, [(MessageCapsule*)obj dateStr]);
//    }];
////    StrippedLog(@"sorted: %@", sorted);
//    
////    NSMutableArray *arrCopy = [sortee mutableCopy];
////    [arrCopy sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
////        return [[(MessageCapsule*)obj2 msgDate] compare:[(MessageCapsule*)obj1 msgDate]];
////    }];
//    
//    
//    return sorted;
//}

// converts array of date formatted strings into NSDate objects
-(NSArray*)convertDateStringArrayToDateArray:(NSArray*)strArr
{
    NSMutableArray *dateArray = [NSMutableArray array];
    [[strArr copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDate *newDate = [self dateFromString:obj];
        [dateArray addObject:newDate];
    }];
    return dateArray;
}

@end

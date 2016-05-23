/*
 *  NSString+PropertyKVC.m
 *
 */

#import "NSString+PropertyKVC.h"

@implementation NSString (AQPropertyKVC)

- (NSString *) propertyStyleString
{
    NSString * result = [[self substringToIndex: 1] lowercaseString];
    if ( [self length] == 1 )
        return ( result );

    return ( [result stringByAppendingString: [self substringFromIndex: 1]] );
}

@end

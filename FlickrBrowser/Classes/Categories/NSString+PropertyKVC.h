/*
 *  NSString+PropertyKVC.h
 *
 */

#import <Foundation/NSString.h>

// Utility function to convert KVC values into property-style values

@interface NSString (AQPropertyKVC)

- (NSString *) propertyStyleString;

@end

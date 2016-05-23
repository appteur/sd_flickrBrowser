//
//  UIFont+Extensions.m
//  cosplayconnect
//
//  Created by Seth on 2/27/16.
//  Copyright © 2016 Seth Arnott. All rights reserved.
//

#import "UIFont+Extensions.h"
#import <CoreText/CoreText.h>

@implementation UIFont (Extensions)

+(void) registerFontWithFilename:(NSString*)filename
{
    NSString *filepath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    
    if (filepath)
    {
//        CFURLRef url = (__bridge CFURLRef)[NSURL URLWithString:filepath];
//        CFErrorRef error;
//        if (! CTFontManagerRegisterFontsForURL(url, kCTFontManagerScopeUser, &error))
//        {
//            CFStringRef errorDescription = CFErrorCopyDescription(error);
//            StrippedLog(@"Failed to load font: [%@] with path: [%@] --  %@", filename, filepath, errorDescription);
//            CFRelease(errorDescription);
//        }
//        else
//        {
//            StrippedLog(@"Registered font with filename: [%@] ... path: [%@]", filename, filepath);
//        }
//        
//        CFRelease(url);
        
        NSData *inData = [NSData dataWithContentsOfFile:filepath];
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (! CTFontManagerRegisterGraphicsFont(font, &error))
        {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            NSLog(@"Failed to load font: [%@] with path: [%@] --  %@", filename, filepath, errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
    else
    {
        NSLog(@"Filepath not found for font: [%@]", filename);
    }
    
}

@end

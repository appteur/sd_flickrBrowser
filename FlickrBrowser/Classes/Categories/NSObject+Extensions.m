//
//  NSObject+Extensions.m
//  connectionTest
//
//  Created by Seth on 10/21/14.
//  Copyright (c) 2014 MyCompany. All rights reserved.
//

#import "NSObject+Extensions.h"
#import <objc/runtime.h>

#import "NSObject+Properties.h"


#define DEBUG_ON NO


@implementation NSObject (Extensions)

+ (NSString *) className
{
    return NSStringFromClass(self);
}

- (NSString *) className
{
    return [[self class] className];
}

- (void) logSelectors
{
    int i=0;
    unsigned int mc = 0;
    
    //Get a list of methods
    Method* mlist = class_copyMethodList(object_getClass(self), &mc);
    
    NSLog(@"Object [%@] of class [%@] has %d methods:", self, [self className], mc);
    
    //walk the method list
    for(i=0;i<mc;i++)
    {
        NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
    }
    
}

-(void) loadPropertiesFromDictionary:(NSDictionary*)dictionary
{
    // run through the keys and try to set the values as property values
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop)
     {
         if ([self respondsToSelector:NSSelectorFromString(key)])
         {
             @try
             {
                 if (value && key)
                 {
                     SEL getter = NSSelectorFromString(key);
                     if ([self respondsToSelector:getter])
                     {
                         Class receivedValType = [value class];
                         Class expectedValType = [[self class] expectedValueTypeForPropertyNamed:key];
                         
                         if (! [value isKindOfClass:expectedValType])
                         {
                             if (DEBUG_ON)
                                 NSLog(@"Received wrong type: [%@] for property: [%@], expecting [%@], converting [%@]...", receivedValType, key, expectedValType, value);
                             
                             if (expectedValType == [NSString class])
                             {
                                 if (DEBUG_ON)
                                     NSLog(@"Converting [%@] to string...", value);
                                 
                                 // convert our number into a string
                                 value = [NSString stringWithFormat:@"%@", value];
                             }
                             else if (expectedValType == [NSNumber class] && [value isKindOfClass:[NSString class]])
                             {
                                 if (DEBUG_ON)
                                     NSLog(@"Converting [%@] to NSNumber...", value);
                                 value = ([value rangeOfString:@"."].location != NSNotFound) ? @([value floatValue]) : @([value integerValue]);
                             }
                             else
                             {
                                 if (DEBUG_ON)
                                     NSLog(@"Received wrong type but not converting");
                             }
                         }
                         
                         // try to set the value from the received object on self.
                         [self setValue:value forKey:key];
                     }
                     else
                     {
                         if (DEBUG_ON)
                             NSLog(@"Failure - not setting value: [%@] does not respond to selector: [%@]", [self class], key);
                     }
                 }
                 else
                 {
                     if (DEBUG_ON)
                         NSLog(@"Failure - value or key null setting value: [%@] for key: [%@] in class: [%@]", value, key, [self class]);
                 }
                 
             }
             @catch (NSException *exception) {
                 NSLog(@"Failed to set value: %@ for key: %@ on object: %@", [value description], key, self);
             }
         }
     }];
}

-(void) loadPropertiesFrom:(NSObject*)object
{
    // get all the property names from the received object
    NSArray *propertyNames = [object propertyNamesArray];
    
    // run through the properties and try to load them from the received object
    [propertyNames enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         id value = [object valueForKey:key];
         
         @try
         {
             if (value && key)
             {
                 SEL getter = NSSelectorFromString(key);
                 if ([self respondsToSelector:getter])
                 {
                     // try to set the value from the received object on self.
                     [self setValue:value forKey:key];
                 }
                 else
                 {
                     if (DEBUG_ON)
                         NSLog(@"Failure - not setting value: [%@] does not respond to selector: [%@]", [self class], key);
                 }
             }
             else
             {
                 if (DEBUG_ON)
                     NSLog(@"Failure - value or key null setting value: [%@] for key: [%@] in class: [%@]", value, key, [self class]);
             }
         }
         @catch (NSException *exception)
         {
#ifdef DEBUG
             NSLog(@"Failed transfer value: [%@] forKey: [%@] from object: [%@] to object: [%@]", value, key, object, self);
#endif
         }
         
     }];
}

-(void) logProperties
{
    NSArray *properties = [self propertyNamesArray];
    
    [properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSString *selector = [obj isKindOfClass:[NSString class]] ? obj : nil;
         
         if (! selector)
         {
             return;
         }
         
         SEL method = NSSelectorFromString(selector);
         
         if ([self respondsToSelector:method])
         {
             id value = [self valueForKey:obj];
             
             NSLog(@"Property: %@ -- Value: %@", obj, value);
         }
     }];
}


-(NSArray*) propertyNamesArray
{
    NSMutableArray *propertyNamesArray = [NSMutableArray array];
    
    // setup counter at 0
    unsigned int count=0;
    
    // get our properties in a c array
    objc_property_t *props = class_copyPropertyList([self class],&count);
    
    for ( int i=0; i<count ;i++ )
    {
        // get the property name as a char
        const char *name = property_getName(props[i]);
        
        //        const char *attributes = property_getAttributes(props[i]);
        
        // convert to nsstring
        NSString *property = [NSString stringWithUTF8String:name];
        
        // add to our array
        [propertyNamesArray addObject:property];
        
        //        StrippedLog(@"property %d: %s -- %s",i,name,attributes);
    }
    
    return propertyNamesArray;
}

-(BOOL) isIphone
{
    return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone);
}

-(BOOL) isIpad
{
    return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
}

+(BOOL) isIphone
{
    return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone);
}

+(BOOL) isIpad
{
    return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
}


-(CGSize) screenSize
{
    return [[UIScreen mainScreen] bounds].size;
}


@end

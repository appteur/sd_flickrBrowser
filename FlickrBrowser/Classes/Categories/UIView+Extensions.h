//
//  UIView+Extensions.h
//  connectionTest
//
//  Created by Seth on 2/7/15.
//  Copyright (c) 2015 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extensions)

-(void) addBlurWithStyle:(UIBlurEffectStyle)style;

-(UIView*) snapshot;
-(UIImage*)snapshotImage;
-(UIImage*) snapshotViewHierarchy;
-(NSData*) snapshotData;

-(void) growWithScale:(CGFloat)scale fadeWithAlpha:(CGFloat)alpha;
-(void) returnToDefault;

-(void) addCircleMask;

@end

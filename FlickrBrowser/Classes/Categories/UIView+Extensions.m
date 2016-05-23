//
//  UIView+Extensions.m
//  connectionTest
//
//  Created by Seth on 2/7/15.
//  Copyright (c) 2015 MyCompany. All rights reserved.
//

#import "UIView+Extensions.h"

@implementation UIView (Extensions)


-(void) addBlurWithStyle:(UIBlurEffectStyle)style
{
    if (! UIAccessibilityIsReduceTransparencyEnabled())
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:blurEffectView];
    }
    else
    {
        self.alpha = 0.6;
    }
}


-(UIView*) snapshot
{
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

-(UIImage*)snapshotImage
{
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(NSData*) snapshotData
{
    NSData *pngData = UIImagePNGRepresentation([self snapshotViewHierarchy]);
    return pngData;
}

-(UIImage*) snapshotViewHierarchy
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copied;
}



-(void) returnToDefault
{
    [UIView animateWithDuration:0.2 animations:^{
        self.transform  = CGAffineTransformIdentity;
        self.alpha      = 1.0;
    }];
}

-(void) growWithScale:(CGFloat)scale fadeWithAlpha:(CGFloat)alpha
{
    [UIView animateWithDuration:0.2 animations:^{
        self.transform  = CGAffineTransformMakeScale(scale, scale);
        self.alpha      = alpha;
    }];
}


-(void) addCircleMask
{
    CGRect tFrame = self.frame;
    
    CGFloat diameter = MIN(tFrame.size.width, tFrame.size.height);
    
    // Make a circular shape path
    UIBezierPath *circularPath  = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, diameter, diameter)
                                                             cornerRadius:diameter];
    // create shape layer
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path          = circularPath.CGPath;
    
    self.layer.mask = circle;
}



@end

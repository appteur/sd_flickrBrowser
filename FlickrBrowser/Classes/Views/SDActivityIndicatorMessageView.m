//
//  SDActivityIndicatorMessageView.m
//  memoryprank
//
//  Created by Seth on 7/31/15.
//  Copyright (c) 2015 arnottindustriesinc. All rights reserved.
//

#import "SDActivityIndicatorMessageView.h"


#define kSpinnerDiameter    80


@interface SDActivityIndicatorMessageView()

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) UILabel *message;

@end


@implementation SDActivityIndicatorMessageView


-(void) dealloc
{
    self.message = nil;
    self.activityIndicatorView = nil;
}

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupMessageLabel];
        [self createBackgroundView];
        [self setupSpinner];
        
    }
    return self;
}

-(void) setTitle:(NSString *)title
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    if (!title)
    {
        return;
    }
    
    NSLog(@"Setting title: [%@]", title);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.message.text = title;
    });
}

-(void) createBackgroundView
{
    UIView *translucentBg            = [[UIView alloc] initWithFrame:self.bounds];
    translucentBg.backgroundColor    = [UIColor blackColor];
    translucentBg.alpha              = 0.80;
    translucentBg.layer.cornerRadius = 5.0;
    translucentBg.clipsToBounds      = YES;
    
    [self insertSubview:translucentBg atIndex:0];
}

-(void) setupSpinner
{
    NSInteger spinnerPadding          = 10;
    self.activityIndicatorView.center = CGPointMake(self.bounds.size.width * 0.5, (kSpinnerDiameter * 0.5) + spinnerPadding);
    [self.activityIndicatorView startAnimating];
    
    [self addSubview:self.activityIndicatorView];
}

-(void) setupMessageLabel
{
    NSInteger labelPadding       = 15.0;
    self.message                 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - (labelPadding*2), 30)];
    self.message.backgroundColor = [UIColor clearColor];
    self.message.textColor       = [UIColor whiteColor];
    self.message.textAlignment   = NSTextAlignmentCenter;
    self.message.font            = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:14];
    self.message.text            = @"Loading...";
    self.message.center          = CGPointMake(self.bounds.size.width * 0.5, 100);
    
    [self addSubview:self.message];
    
}


-(UIActivityIndicatorView*) activityIndicatorView
{
    if(! _activityIndicatorView)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kSpinnerDiameter, kSpinnerDiameter)];
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return _activityIndicatorView;
}



@end

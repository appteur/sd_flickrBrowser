//
//  SDProfileHeaderView.m
//  cosplayconnect
//
//  Created by Seth on 2/26/16.
//  Copyright © 2016 Seth Arnott. All rights reserved.
//

#import "SDProfileHeaderView.h"
#import "UIView+Extensions.h"

@implementation SDProfileHeaderView

-(instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupView];
    }
    return self;
}


-(void) setupView
{
    CGFloat verticalCenter  = (self.bounds.size.height / 2) + 5;
    CGFloat leftMargin      = 10.0;
    CGFloat horizontalSpace = 10.0;
    
    // make image size the height of the header minus padding top/bottom, set width the same to make it square
    CGFloat width_height = self.bounds.size.height - horizontalSpace * 2;
    self.image_icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_height, width_height)];
    // apply circular mask to image
    [self.image_icon addCircleMask];
    
    // justify image to the left and add padding on the left
    self.image_icon.center = CGPointMake(self.image_icon.bounds.size.width + horizontalSpace, verticalCenter);
    
    [self addSubview:self.image_icon];
    
    // setup name label left justified
    self.label_name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 190.0, 34.0)];
    // position the name label to the right of the image icon
    self.label_name.center = CGPointMake(self.image_icon.frame.origin.x + self.image_icon.bounds.size.width + leftMargin + (self.label_name.bounds.size.width / 2), verticalCenter);
    [self.label_name setFont:[UIFont fontWithName:@"BrandonGrotesque-Regular" size:20.0]];
    
    // setup description label just to the right of name label
//    self.label_description = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30.0, 34.0)];
//    
//    // calculate points for age label position
//    CGFloat nameRightEdge = self.label_name.center.x + (self.label_name.bounds.size.width / 2);
//    CGFloat ageXPos       =  nameRightEdge + (self.label_description.bounds.size.width / 2) + horizontalSpace;
//    
//    self.label_description.center = CGPointMake(ageXPos, verticalCenter);
//    [self.label_description setFont:[UIFont fontWithName:@"BrandonGrotesque-Regular" size:23.0]];
    
    
    // setup distance label
    self.label_timestamp = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70.0, 34.0)];
    self.label_timestamp.textAlignment = NSTextAlignmentRight;
    // position timestamp label on the right top of the header
    self.label_timestamp.center = CGPointMake(self.bounds.size.width - self.label_timestamp.bounds.size.width - 5, verticalCenter);
    [self.label_timestamp setFont:[UIFont fontWithName:@"BrandonGrotesque-Regular" size:15.0]];
    
    
    [self addSubview:self.label_name];
    [self addSubview:self.label_description];
    [self addSubview:self.label_timestamp];
}


@end

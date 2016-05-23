//
//  MapSelectionViewController.h
//  SketchMessenger
//
//  Created by Seth on 11/12/15.
//  Copyright © 2015 arnottindustriesinc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapSelectionViewController : UIViewController

@property (nonatomic, copy) void (^mapSelectCompletion)(NSNumber *latitude, NSNumber *longitude, NSString *location);

@end

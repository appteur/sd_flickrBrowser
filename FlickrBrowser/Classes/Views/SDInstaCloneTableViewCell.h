//
//  SDInstaCloneTableViewCell.h
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDInstaCloneTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image_main;

@property (weak, nonatomic) IBOutlet UIView *view_btn_container;
@property (weak, nonatomic) IBOutlet UILabel *label_description;



@end

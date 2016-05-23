//
//  SDPhotoFeedViewController.m
//  FlickrBrowser
//
//  Created by Seth on 4/28/16.
//  Copyright © 2016 aii. All rights reserved.
//

#import "SDPhotoFeedViewController.h"

#import "ViewModelPhotoFeed.h"

// custom views
#import "SDInstaCloneTableViewCell.h"
#import "SDProfileHeaderView.h"

// data objects
#import "SDFlickrResultData.h"

// view controllers
#import "MapSelectionViewController.h"

// activity indicator
#import "SDActivityIndicatorMessageView.h"

// network change notifications
#import "SDNetworkNotificationDefines.h"


@interface SDPhotoFeedViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;

// array of SDFlickrResultData objects
@property (nonatomic, strong) NSMutableArray *tabledata;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isScrollingDown;
@property (nonatomic, assign) BOOL shouldClearTabledata;

@property (nonatomic, strong) ViewModelPhotoFeed *viewModel;

// segmented control
@property (weak, nonatomic) IBOutlet UISegmentedControl *displayControl;

// search
@property (weak, nonatomic) IBOutlet UITextField *textfield_search;
@property (weak, nonatomic) IBOutlet UIButton *btn_search;

// constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_tablview_top;


// activity indicator
@property (nonatomic, strong) SDActivityIndicatorMessageView *activityIndicatorView;

// tracks when offline notice is displayed to prevent spamming user
@property (nonatomic, assign) NSTimeInterval offlineNoticeDisplayTime;

@end

@implementation SDPhotoFeedViewController


-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        // add listener for network status changes to notify user if network is unavailable
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notif_networkStatusChanged:)
                                                     name:kSDNetworkConnectionDidChangeNotification
                                                   object:nil];
        
        self.tabledata  = [NSMutableArray array];
        self.viewModel  = [[ViewModelPhotoFeed alloc] init];
        self.offlineNoticeDisplayTime = 0;
        
        self.currentPage = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notif_appDidResume:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(actionRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableview addSubview:refresh];
    
    // load recent posts on first load
    [self loadRecentPosts];
}


-(void) actionRefresh:(UIRefreshControl*)sender
{
    self.currentPage = 0;
    
    switch (self.displayControl.selectedSegmentIndex)
    {
        case 0:  [self loadRecentPosts];    break;
        case 1:  [self loadSearchPosts];    break;
        case 2:  [self loadLocationPosts];  break;
        default: [self loadRecentPosts];    break;
    }
    
    [sender endRefreshing];
}


/*
    Requests posts in the recent past.
 */
-(void) loadRecentPosts
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    SDPhotoFeedViewController *__weak weakself = self;
    self.currentPage += 1;
    
    // show spinner if we aren't currently looking at photos
    if (self.currentPage == 1)
    {
        [self showActivitySpinnerWithTitle:@"Loading recent posts..."];
    }
    
    // fetch the next page of results
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.viewModel doFetchFeedWithPage:@(self.currentPage) completion:^(NSArray *results, NSError *error) {
            [weakself handleFetchResponseWithResults:results error:error];
        }];
    });
}


/*
    Requests posts using search term provided by user.
 */
-(void) loadSearchPosts
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    if (self.textfield_search.text.length < 1)
    {
        NSLog(@"No term to use for search...");
        return;
    }
    
    // show spinner if we're not prefetching next batch
    if (self.currentPage == 1)
    {
        [self showActivitySpinnerWithTitle:@"Loading search results..."];
    }
    
    SDPhotoFeedViewController *__weak weakself = self;
    self.currentPage += 1;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.viewModel doFetchFeedForSearchTerm:self.textfield_search.text page:@(self.currentPage) completion:^(NSArray *results, NSError *error) {
            [weakself handleFetchResponseWithResults:results error:error];
        }];
    });
}


/*
    Requests posts near a users location (default 25km)
 */
-(void) loadLocationPosts
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    SDPhotoFeedViewController *__weak weakself = self;
    self.currentPage += 1;
    
    // show spinner
    if (self.currentPage == 1)
    {
        [self showActivitySpinnerWithTitle:@"Loading posts near you..."];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.viewModel doFetchFeedWithPage:@(self.currentPage) radius:@(25) completion:^(NSArray *results, NSError *error) {
            [weakself handleFetchResponseWithResults:results error:error];
        }];
    });
}

/*
    Handles results returned from 3 prior load requests.
    Handles error if one exists and notifies user, if we just changed modes (recent/search/location) we will remove all current results
        and load new results into our tabledata before refreshing the tableview.
 */
-(void) handleFetchResponseWithResults:(NSArray*)results error:(NSError *)error
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    // hide activity spinner
    [self hideActivitySpinner];
    
    if (error)
    {
        // TODO: handle error
        if (error.code == -1009)
        {
            // show offline notice
            [self showNetworkAlertWithTitle:@"Connection Offline" message:error.localizedDescription];
        }
        
        
        return;
    }
    
    if (results && results.count > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.currentPage == 1)
            {
                // if we've reset our page count then clear tabledata contents and load all new data
                [self.tabledata removeAllObjects];
                
            }
            
            // add all new results (append if not initial page load)
            [self.tabledata addObjectsFromArray:results];
            [self.tableview reloadData];
        });
    }
}


/*
    Convenience method to determine scroll direction for loading next set of results from api.
 */

-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.isScrollingDown = (velocity.y < 0) ? YES : NO;
}


#pragma mark - Tableview Datasource/Delegate methods -

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // we have one profile per section (sticky header)
    return 1;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    // we want one header per cell for this application
    return self.tabledata.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoFeedCell";
    SDInstaCloneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SDInstaCloneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.frame = CGRectMake(2, 2, tableView.frame.size.width - 4, 30);
    }
    
    [cell.image_main setImage:nil];
    
    // grab photo data for this cell/section
    SDFlickrResultData *resultData = self.tabledata.count > indexPath.section ? self.tabledata[indexPath.section] : nil;
    
    if (resultData)
    {
        // load main image in the background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.viewModel fetchImageWithData:resultData completion:^(UIImage *image, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // only load the image if the cell is still visible (on the main thread)
                    if ([tableView.indexPathsForVisibleRows containsObject:indexPath])
                    {
                        if (image)
                        {
                            [cell.image_main setImage:image];
                        }
                    }
                });
                
                if (error)
                {
                    if (error.code == -1009)
                    {
                        // show offline notice
                        [self showNetworkAlertWithTitle:@"Connection Offline" message:error.localizedDescription];
                    }
                }
            }];
        });
        
        
        // set title label text
        cell.label_description.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:12.0];
        cell.label_description.numberOfLines = 0;
        cell.label_description.lineBreakMode = NSLineBreakByWordWrapping;
        cell.label_description.alpha = 0.7;
        cell.label_description.text = resultData.title ?: @"";
    }
    
    // preload our next page if we are within 10 profiles of the end of our current batch
    // and we're not backing up the page
    if (indexPath.section == (self.tabledata.count - 10) && ! self.isScrollingDown)
    {
        switch (self.displayControl.selectedSegmentIndex)
        {
            case 0:  [self loadRecentPosts];    break;
            case 1:  [self loadSearchPosts];    break;
            case 2:  [self loadLocationPosts];  break;
            default: [self loadRecentPosts];    break;
        }
    }
    
    return cell;
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 420.0; // arbitrary height for cell row
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // get profile data for this cell
    SDFlickrResultData *resultData = self.tabledata[section];
    
    // get buddy image, name, description and upload timestamp and set section header properties
    SDProfileHeaderView *header = [[SDProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 48.0)];
    header.backgroundColor = [UIColor whiteColor];
    header.alpha = 0.7;
    
    // load buddy icon
    [self.viewModel fetchBuddyIconWithData:resultData completion:^(UIImage *image, NSError *error) {
        if (image)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [header.image_icon setImage:image];
            });
        }
        
        if (error)
        {
            if (error.code == -1009)
            {
                // show offline notice
                [self showNetworkAlertWithTitle:@"Connection Offline" message:error.localizedDescription];
            }
        }
    }];
    
    // populate header textfields
    header.label_name.text        = resultData.ownername ?: @"";
    header.label_description.text = resultData.title ?: @"";
    header.label_timestamp.text   = [NSString stringWithFormat:@"%@", resultData.dateString];
    
    return header;
}

-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // Add section footer
    CGFloat margin       = 20.0;
    CGFloat footerHeight = 10.0;
    
    CGRect footerFrame = CGRectMake(margin, 0, self.view.bounds.size.width - (margin * 2), footerHeight);
    UIView *footerView = [[UIView alloc] initWithFrame:footerFrame];
    footerView.alpha   = 0.3;
    
    // add border
    CGFloat borderThickness = 0.4;
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [UIColor blackColor].CGColor;
    bottomBorder.frame = CGRectMake(margin, footerHeight - borderThickness, footerFrame.size.width, borderThickness);
    [footerView.layer addSublayer:bottomBorder];
    
    return footerView;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // arbitrary height for section header
    return 60.0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // arbitrary height for section footer
    return 10.0;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // don't do anything, just deselect cell for now
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



- (IBAction)viewModeDidChange:(UISegmentedControl*)sender
{
    NSLog(@"%s -- %d :: segment: [%ld]", __FUNCTION__, __LINE__, (long)sender.selectedSegmentIndex);
    
    // swapping modes so reset page count to 0 so results will load correctly on user engagement
    self.currentPage = 0;
    CGFloat constant = 57;
    
    // reset search textfield
    self.textfield_search.text = @"";
    
    if (sender.selectedSegmentIndex == 0)
    {
        // hide keyboard
        [self.textfield_search resignFirstResponder];
        
        // scroll to top for new recent
        [self.tableview setContentOffset:CGPointZero animated:NO];
        
        // since we just switched to recent posts, (requires no user input) fetch new recent posts now
        [self loadRecentPosts];
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        // switched to search so lower tableview to expose search field
        // and wait for search input
        constant = 127;
        
        // load keyboard
        [self.textfield_search becomeFirstResponder];
    }
    else
    {
        // hide keyboard
        [self.textfield_search resignFirstResponder];
        
        // switched to search via location
        [self showLocationAlert];
    }
    
    self.constraint_tablview_top.constant = constant;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}


-(void) showLocationAlert
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:@"Location Needed"
                                                                         message:@"Provide your location via gps or select your location from a map to get results centered around your location."
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    SDPhotoFeedViewController *__weak weakself = self;
    
    UIAlertAction *gps = [UIAlertAction actionWithTitle:@"Use my location"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                    // show spinner
                                                    [weakself showActivitySpinnerWithTitle:@"Resolving location..."];
                                                    
                                                    weakself.viewModel.onLocationResolve = ^{
                                                        NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
                                                        [weakself loadLocationPosts];
                                                        // don't dismiss spinner here, will be dismissed on fetch complete
                                                    };
                                                    
                                                    // load location via gps
                                                    [weakself.viewModel doResolveMyLocation];
                                                }];
    
    UIAlertAction *map = [UIAlertAction actionWithTitle:@"Select manually"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    
                                                    weakself.viewModel.onLocationResolve = ^{
                                                        NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
                                                        [weakself loadLocationPosts];
                                                    };
                                                    
                                                    // load location via selection from map view
                                                    [weakself.viewModel doSelectLocationFromMapWithParentVC:weakself];
                                                
                                                }];
    
    [actionsheet addAction:gps];
    [actionsheet addAction:map];
    
    actionsheet.popoverPresentationController.sourceView = self.view;
    
    [self presentViewController:actionsheet animated:YES completion:nil];
}

-(void) showNetworkAlertWithTitle:(NSString*)title message:(NSString*)message
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    // don't spam the user with offline notices for every failed request
    // only show the alert once every 2 min
    if (now - self.offlineNoticeDisplayTime > 60 * 2)
    {
        self.offlineNoticeDisplayTime = now;
        
        // notify user of possible connection issues
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
            [alert addAction:cancel];
            alert.popoverPresentationController.sourceView = self.view;
            
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}


- (IBAction)actionSearch:(id)sender
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    if (self.textfield_search.text.length > 0)
    {
        // dismiss keyboard
        [self.textfield_search resignFirstResponder];
        
        // new search so reset current page
        self.currentPage = 0;
        
        // scroll tablview to the top
        [self.tableview setContentOffset:CGPointZero animated:NO];
        
        // we have a search term, so load new images
        [self loadSearchPosts];
        
        // animate tableview back up
        CGFloat constant = 57;
        
        self.constraint_tablview_top.constant = constant;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
    }
}


-(void) showActivitySpinnerWithTitle:(NSString*)title
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    dispatch_async(dispatch_get_main_queue(), ^
       {
           if (!_activityIndicatorView)
           {
               UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
               
               _activityIndicatorView = [[SDActivityIndicatorMessageView alloc] initWithFrame:CGRectMake(0, 0, 180, 120)];
               _activityIndicatorView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
               _activityIndicatorView.center = window.center;
               _activityIndicatorView.layer.cornerRadius = 20;
               
               [window addSubview:_activityIndicatorView];
           }
           
           if (title)
           {
               [_activityIndicatorView setTitle:title];
           }
           
       });
}

-(void) hideActivitySpinner
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    if (self.activityIndicatorView)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.activityIndicatorView removeFromSuperview];
                           self.activityIndicatorView = nil;
                       });
    }
}


#pragma mark - Notification Listeners -

-(void) notif_appDidResume:(NSNotification*)notif
{
    NSLog(@"%s -- %d", __FUNCTION__, __LINE__);
    
    // app is resuming from the background, reset our page count
    self.currentPage = 0;
    
    // reset segmented control to recent posts
    self.displayControl.selectedSegmentIndex = 0;
    
    // load recent posts
    [self loadRecentPosts];
}

-(void) notif_networkStatusChanged:(NSNotification*)notif
{
    // get connection status
    BOOL isConnected = [notif.userInfo[@"isConnected"] boolValue];
    
    if (!isConnected)
    {
        [self showNetworkAlertWithTitle:@"Poor Network" message:@"Network connectivity to flickr is poor over your wireless connection, try connecting to a better network for a better experience"];
    }
    else
    {
        // network reconnected, fetch results now
        self.currentPage = 0;
        
        [self loadRecentPosts];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // TODO: Dispose of any resources that can be recreated.
}


@end

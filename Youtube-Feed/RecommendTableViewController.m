//
//  RecommendTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/11/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "RecommendTableViewController.h"
#import "MainTabBarViewController.h"
#import "RecommendCustomCell.h"
#import "ViewController.h"

#import "AppDelegate.h"
#import <UIEMultiAccess/UIEMultiAccess.h>
#import <UIEMultiAccess/DNApplicationManager.h>
#import <UIEMultiAccess/DNAppCatalog.h>
#import <UIEMultiAccess/UMAApplicationInfo.h>

typedef NS_ENUM(NSInteger, SectionType) {
    SECTION_TYPE_SETTINGS,
    SECTION_TYPE_LAST_CONNECTED_DEVICE,
    SECTION_TYPE_CONNECTED_DEVICE,
    SECTION_TYPE_DISCOVERED_DEVICES,
};

typedef NS_ENUM(NSInteger, AlertType) {
    ALERT_TYPE_FAIL_TO_CONNECT,
    ALERT_TYPE_DISCOVERY_TIMEOUT,
};
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
static NSString *const kSettingsManualConnectionTitle = @"Manual Connection";
static NSString *const kSettingsManualConnectionSubTitle =
@"Be able to select a device which you want to connect.";
static NSString *const kDeviceNone = @"No Name";
static NSString *const kAddressNone = @"No Address";

static NSString *const kRowNum = @"rowNum";
static NSString *const kHeaderText = @"headerText";
static NSString *const kTitleText = @"HID Device Sample";

NSString *const kIsManualConnection = @"is_manual_connection";

@interface RecommendTableViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>

@property (nonatomic, strong) UMAFocusManager *focusManager;
@property (nonatomic, strong) NSArray *applications;
@property (nonatomic) BOOL remoteScreen;
@property (nonatomic) UMAApplication *umaApp;
@property (nonatomic) UMAHIDManager *hidManager;
@property (nonatomic) UMAInputDevice *connectedDevice;
@property (copy, nonatomic) void (^discoveryBlock)(UMAInputDevice *, NSError *);
@property (copy, nonatomic) void (^connectionBlock)(UMAInputDevice *, NSError *);
@property (copy, nonatomic) void (^disconnectionBlock)(UMAInputDevice *, NSError *);
@property (nonatomic) NSMutableArray *inputDevices;

@end

@implementation RecommendTableViewController
{
    BOOL nextPage;
    BOOL backFactRecommended;
    BOOL inTabbar;
    BOOL portraitFact;
    BOOL landscapeFact;
    BOOL scrollKKPTriggered;
    BOOL didReceivedFromYoutubePlaying;
    BOOL currentPlayingFact;
    NSInteger indexFocus;
    NSInteger directionFocus;
    NSInteger indexFocusCatch;
    NSInteger indexFocusTabbar;
    NSInteger markHighlightIndex;
    
    BOOL viewFact;
    BOOL hostActive;
    BOOL internetActive;
    BOOL reloadFact;
}
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    viewFact = NO;
    nextPage = true;
    didReceivedFromYoutubePlaying = NO;
    currentPlayingFact = NO;
    scrollKKPTriggered = NO;
    markHighlightIndex = 0;
    indexFocusCatch = 0;
    directionFocus = 0;
    inTabbar = false;
    hostActive = NO;
    internetActive = NO;
    reloadFact = NO;
    self.youtube = [[Youtube alloc] init];
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.recommendYoutube = [[Youtube alloc] init];
    [self getData];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedSettingNotification:)
                                                 name:@"SettingDidSelected" object:nil];
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Recommended", nil)];
    
    self.recommendedTitle.text = [NSString stringWithFormat:NSLocalizedString(@"Recommended", nil)];
    self.recommendedIconTitle.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubePlayingNotification:)
                                                 name:@"YoutubePlaying" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubeReloadNotification:)
                                                 name:@"YoutubeReload" object:nil];

    [self.settingButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Setting", nil)] forState:UIControlStateNormal];
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x4F6366);

    

#pragma setup UMA in ViewDidload in RecommendTableView

     _umaApp = [UMAApplication sharedApplication];
     _umaApp.delegate = self;
     [_umaApp addViewController:self];
   
    //focus
      _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
      [_focusManager setFocusRootView:self.tableView];
      [_focusManager setHidden:NO];

}

- (void)checkNetworkStatus:(NSNotification *)notification
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus) {
        case NotReachable:
        {

            internetActive = NO;
            break;
            
        }
        case ReachableViaWiFi:
        {

            internetActive = YES;
            break;
            
        }
        case ReachableViaWWAN:
        {

            internetActive = YES;
            break;
            
        }
            
            
        default:
            break;
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {

            hostActive = NO;
            
            break;
        }
        case ReachableViaWiFi:
        {

            hostActive = YES;
            
            break;
        }
        case ReachableViaWWAN:
        {

            hostActive = YES;
            
            break;
        }
    }

   [self showingNetworkStatus];
  
}

 - (void)showingNetworkStatus
{
    if (internetActive) {
        if(reloadFact){
            reloadFact = NO;
            [self launchReload];
        }

    } else {
        reloadFact = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoIdNextPage" object:nil];

    }
    
}




- (void)receivedYoutubePlayingNotification:(NSNotification *)notification
{
    Youtube *youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    NSInteger selectedIndex = [[notification.userInfo objectForKey:@"youtubeCurrentPlaying"] integerValue];
    self.recommendPlaying = [[notification.userInfo objectForKey:@"recommendFact"] boolValue];
    if (self.recommendPlaying) {
        if ([[youtube.videoIdList objectAtIndex:selectedIndex] isEqualToString:[self.recommendYoutube.videoIdList objectAtIndex:selectedIndex]])
        {
            didReceivedFromYoutubePlaying = YES;
            self.selectedRow = selectedIndex;
            [self.tableView reloadData];
            
        } else {
            
            didReceivedFromYoutubePlaying = NO;
            [self.tableView reloadData];

        }
        
    } else {
        
        didReceivedFromYoutubePlaying = NO;
        [self.tableView reloadData];
    }


}

- (void)receivedYoutubeReloadNotification:(NSNotification *)notification
{
    MainTabBarViewController *mainTabbar = (MainTabBarViewController *)self.tabBarController;
    self.recommendYoutube = mainTabbar.recommendYoutube;
    self.genreSelected = mainTabbar.genreSelected;
    [self.tableView reloadData];

}

- (void)prepareBlocks
{
    __weak typeof(self) weakSelf = self;
    
    //
    // Block of Discovery Completion
    //
    _discoveryBlock = ^(UMAInputDevice *device, NSError *error) {
        UIAlertView *alertView;
        
        switch ([error code]) {
            case kUMADiscoveryDone: // Intentionally stops by the app
            case kUMADiscoveryFailed: // Discovery failed with some reason
                //[weakSelf.refreshControl endRefreshing];
                break;
            case kUMADiscoveryTimeout: // Timeout occurred
                [weakSelf.hidManager stopDiscoverDevice];
                alertView = [[UIAlertView alloc] initWithTitle:@"Discovery of HID Device finished"
                                                       message:@"If you would like to discover again, pull down the view."
                                                      delegate:weakSelf
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
                alertView.tag = ALERT_TYPE_DISCOVERY_TIMEOUT;
                [alertView show];
                //[weakSelf.refreshControl endRefreshing];
                break;
            case kUMADiscoveryDiscovered:       // Device discovered
                /* Get discovered devices and reload table*/
                [weakSelf.inputDevices addObject:device];
                //[weakSelf.sampleTableView reloadData];
                break;
            case kUMADiscoveryStarted:
                break;
            default:
                break;
        }
    };
    [_hidManager setDiscoveryCallback:_discoveryBlock];
    
    //
    // Block of Connection Complete
    //
    _connectionBlock = ^(UMAInputDevice *device, NSError *error) {
        UIAlertView *alertView;
        switch ([error code]) {
            case kUMAConnectedSuccess:
                [weakSelf.hidManager stopDiscoverDevice];
                weakSelf.connectedDevice = device;
                //[weakSelf.sampleTableView reloadData];
                break;
            case kUMAConnectedTimeout:
            case kUMAConnectedFailed:
                alertView =
                [[UIAlertView alloc] initWithTitle:@"Connection timeout occurred."
                                           message:@"Reset the last memory and start to discovery?"
                                          delegate:weakSelf
                                 cancelButtonTitle:@"No"
                                 otherButtonTitles:@"Yes", nil];
                alertView.tag = ALERT_TYPE_FAIL_TO_CONNECT;
                [alertView show];
                break;
            default:
                break;
                
        }
    };
    [_hidManager setConnectionCallback:_connectionBlock];
    
    //
    // Block of Disonnection Complete
    //
    _disconnectionBlock = ^(UMAInputDevice *device, NSError *error) {
        weakSelf.connectedDevice = nil;
        //[weakSelf.sampleTableView reloadData];
    };
    [_hidManager setDisconnectionCallback:_disconnectionBlock];
}

- (void)orientationChanged:(NSNotification *)notification
{
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }

    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];

    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        if (scrollKKPTriggered) {
            if (portraitFact) {
                if (backFactRecommended) {
                    [_focusManager setFocusRootView:self.tableView];
                    [_focusManager setHidden:NO];
                    if (indexFocus == [self.recommendYoutube.videoIdList count]-1) {
                        [_focusManager moveFocus:indexFocus];
                    } else {
                        
                        if (indexFocus == 0) {
                            if (directionFocus == 1) {
                                [_focusManager moveFocus:indexFocus];
                            } else {
                                [_focusManager moveFocus:[_focusManager focusIndex]];
                            }
                        } else {
  
                            [_focusManager moveFocus:indexFocus];
                        }
                        
                    }
                    
                } else {
                    
                    [_focusManager setFocusRootView:self.tabBarController.tabBar];
                    [_focusManager setHidden:NO];
                    [_focusManager moveFocus:indexFocusTabbar];
                    
                }
                portraitFact = NO;
                landscapeFact = YES;
            }

        } else {
            [_focusManager setHidden:YES];
             //[_focusManager lock];
        }
        
    } else {
        if (scrollKKPTriggered) {
            if (landscapeFact) {
                if (backFactRecommended) {
                    [_focusManager unlock];
                    [_focusManager setFocusRootView:self.tableView];
                    [_focusManager setHidden:NO];
                    if (indexFocus == [self.recommendYoutube.videoIdList count]-1) {
                        [_focusManager moveFocus:indexFocus];
                    } else {
                        
                        
                        if (indexFocus == 0) {
                            if (directionFocus == 1) {
                                [_focusManager moveFocus:indexFocus];
                            } else {
                                [_focusManager moveFocus:[_focusManager focusIndex]];
                            }
                            
                        } else {
                            
                            [_focusManager moveFocus:indexFocus];
                        }
                        
                    }
                    
                } else {
                    
                    [_focusManager setFocusRootView:self.tabBarController.tabBar];
                    [_focusManager setHidden:NO];
                    [_focusManager moveFocus:indexFocusTabbar];
                    
                }
                portraitFact = YES;
                landscapeFact = NO;
            }

        } else {
            //[_focusManager setFocusRootView:self.tableView];
            //[_focusManager moveFocus:0];
            //[_focusManager lock];
             [_focusManager setHidden:YES];
        }

    }

}


- (void)getData
{
    MainTabBarViewController *mainTabbar = (MainTabBarViewController *)self.tabBarController;
    self.recommendYoutube = mainTabbar.recommendYoutube;
    self.genreSelected = mainTabbar.genreSelected;
}

- (void)receivedSettingNotification:(NSNotification *)notification
{

    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    //global objects
    backFactRecommended = YES;
    scrollKKPTriggered = YES;
    viewFact = YES;

//    
    MainTabBarViewController *mainTabbar = (MainTabBarViewController *)self.tabBarController;
    self.recommendYoutube = mainTabbar.recommendYoutube;
    self.genreSelected = mainTabbar.genreSelected;


    indexFocusTabbar = 1;
    indexFocus = 1;
    portraitFact = YES;
    landscapeFact = YES;
    reloadFact = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    if (self.recommendPlaying) {
        didReceivedFromYoutubePlaying = YES;
        [self.tableView reloadData];
    } else {
        didReceivedFromYoutubePlaying = NO;

    }
    
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    hostReachable = [Reachability reachabilityWithHostName:@"www.youtube.com"];
    [hostReachable startNotifier];
#pragma setup UMA in ViewDidAppear in RecommendTableView
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager moveFocus:1];
    [_focusManager setHidden:NO];

}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [_focusManager setHidden:YES];
    viewFact = NO;
    for (UIView *subView in self.navigationController.navigationBar.subviews) {
        if (subView.tag == 99) {
            [subView removeFromSuperview];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.recommendYoutube.videoIdList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecommendCustomCell";
    RecommendCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    if (didReceivedFromYoutubePlaying) {
        if (indexPath.row == self.selectedRow) {
            cell.contentView.backgroundColor = UIColorFromRGB(0xFFCCCC);
            markHighlightIndex = indexPath.row;
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
  
    if ([self.recommendYoutube.durationList count] == [self.recommendYoutube.videoIdList count]) {
        cell.name.text = [self.recommendYoutube.titleList objectAtIndex:indexPath.row];
        cell.tag = indexPath.row;
        NSString *duration = [self.recommendYoutube.durationList objectAtIndex:indexPath.row];
        cell.durationLabel.text = [self durationText:duration];
        
        cell.thumnail.image = nil;
        //
        if([self.recommendYoutube.thumbnailList objectAtIndex:indexPath.row] != [NSNull null]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.recommendYoutube.thumbnailList objectAtIndex:indexPath.row]]];
                
                if(data){
                    [self.imageData addObject:data];
                    UIImage* image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(cell.tag == indexPath.row){
                                cell.thumnail.image = image;
                                [cell setNeedsLayout];
                            }
                        });
                    }
                }
            });
        }
 
    }
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    [self.delegate recommendTableViewControllerDidSelected:self];
    [self.tabBarController setSelectedIndex:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{

    scrollKKPTriggered = NO;
    [_focusManager setHidden:YES];
    
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h + reload_distance) {
        if (nextPage) {
            reloadFact = YES;
            [self launchReload];
        }
    }
}

- (void)launchReload
{

    nextPage = false;
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = CGRectMake(0, 0, 320, 44);
    spinner.color = [UIColor blackColor];
    self.tableView.tableFooterView = spinner;
    [spinner startAnimating];
    
    [self.recommendYoutube callRecommendSearch:self.genreSelected withNextPage:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoIdNextPage)
                                                 name:@"LoadVideoIdNextPage" object:nil];
    
}

- (NSString *)durationText:(NSString *)duration
{

    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    if (hours != 0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    


}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
}

- (void)receivedLoadVideoIdNextPage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        self.tableView.tableFooterView = nil;
        
        [self.tableView reloadData];
        nextPage = true;
        reloadFact = NO;

        if (scrollKKPTriggered) {
            if (directionFocus == 0) {
                [_focusManager moveFocus:indexFocus+=25];
                indexFocus-=25;
            } else {
                [_focusManager moveFocus:indexFocus];
            }

        }
         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadVideoIdNextPage" object:nil];
    });
   
}



- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    if (viewFact == NO) {
        return  YES;
    }
  
    scrollKKPTriggered = YES;
    [_focusManager setHidden:NO];

    if (nextPage == 0) {
        return YES;
        
    } else {

        if (backFactRecommended == 0) {

            if (direction == 1) {
                
                if ([_focusManager focusIndex] == 0 && distance == 1) {
                    indexFocusTabbar = 4;
                    
                }else if ([_focusManager focusIndex] == 3 && distance == 1) {
                    indexFocusTabbar = 3;
                    
                }else if ([_focusManager focusIndex] == 2 && distance == 1) {
                    indexFocusTabbar = 1;
                }
            } else {
                
                if ([_focusManager focusIndex] == 0 && distance == 1) {
                    indexFocusTabbar = 3;
                } else if ([_focusManager focusIndex] == 2 && distance == 1) {
                    indexFocusTabbar = 4;
                } else if ([_focusManager focusIndex] == 3 && distance == 1) {
                    indexFocusTabbar = 1;
                }
                
            }
            
            if ([_focusManager focusIndex] == 3 && distance == 1 && direction == 0) {
                [_focusManager moveFocus:1];
            } else if ([_focusManager focusIndex] == 0 && distance == 1 && direction == 1) {
                [_focusManager moveFocus:4];
            } else if ([_focusManager focusIndex] == 2 && distance == 1 && direction == 1) {
                [_focusManager moveFocus:4];
            } else if ([_focusManager focusIndex] == 0 && distance == 1 && direction == 0) {
                [_focusManager moveFocus:1];
            }
            
        }
        
        indexFocus = [_focusManager focusIndex];
        
        if (direction == 0) {
            indexFocus+=2;
            directionFocus = 0;
            if (indexFocus == [self.recommendYoutube.videoIdList count]) {
                if (nextPage) {
                    [self launchReload];
                    
                }
            }
        } else {
            directionFocus = 1;
            if (indexFocus == 0) {
                if (nextPage) {
                    [self launchReload];
                    
                }
            }


        }
        return NO;
        
    }
    

}
- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY
{
    if (viewFact == NO) {
        return  YES;
    }
    
    if (nextPage == 0) {
        [_focusManager lock];
        return  YES;
    } else {
        
        if (backFactRecommended) {
            [_focusManager unlock];
            scrollKKPTriggered = YES;
            [_focusManager setHidden:NO];
            indexFocus = [_focusManager focusIndex];
            
            if (distanceX == 0 && distanceY == 1) {
                [_focusManager moveFocus:1 direction:kUMAFocusForward];
                indexFocus+=2;
                directionFocus = 0;
                if (indexFocus == [self.recommendYoutube.videoIdList count]) {
                    //reload data nextPage
                    if (nextPage) {
                        [self launchReload];
                    }
                }
            } else if (distanceX == 0 && distanceY == -1) {
               
                [_focusManager moveFocus:1 direction:kUMAFocusBackward];
                directionFocus = 1;
                if (indexFocus == 0) {
                    if (nextPage) {
                        [self launchReload];
                    }
                }
            }
            
            return YES;
        } else {
            
            if (distanceX == 1 && distanceY == 0) {
                if ([_focusManager focusIndex] == 0 ) {
                    indexFocusTabbar = 3;
                } else if ([_focusManager focusIndex] == 2 ) {
                    indexFocusTabbar = 4;
                } else if ([_focusManager focusIndex] == 3 ) {
                    indexFocusTabbar = 1;
                }
                
                if ([_focusManager focusIndex] == 0) {
                    [_focusManager moveFocus:1];
                    
                    
                } else if ([_focusManager focusIndex] == 3) {
                    [_focusManager moveFocus:1];
                    
                }
            }else if (distanceX == -1 && distanceY == 0) {
              
                if ([_focusManager focusIndex] == 0 ) {
                    indexFocusTabbar = 4;
                    
                } else if ([_focusManager focusIndex] == 3 ) {
                    indexFocusTabbar = 3;
                    
                } else if ([_focusManager focusIndex] == 2 ) {
                    indexFocusTabbar = 1;
                }
                
                if ([_focusManager focusIndex] == 0) {
                    [_focusManager moveFocus:4];
                    
                } else if ([_focusManager focusIndex] == 2) {
                    [_focusManager moveFocus:4];
                    
                }
            }else if (distanceX == 0 && distanceY == 1) {

            }else if (distanceX == 0 && distanceY == -1) {
                
            }
            return NO;
            
            
        }

    }
    
    
}



- (NSString *)getButtonName:(UMAInputButtonType)button
{
    switch (button) {
        case kUMAInputButtonTypeBack:
            return @"Back";
        case kUMAInputButtonTypeDown:
            return @"Down";
        case kUMAInputButtonTypeHome:
            return @"Home";
        case kUMAInputButtonTypeLeft:
            return @"Left";
        case kUMAInputButtonTypeMain:
            return @"Main";
        case kUMAInputButtonTypeRight:
            return @"Right";
        case kUMAInputButtonTypeUp:
            return @"UP";
        case kUMAInputButtonTypeVR:
            return @"VR";
        default:
            return @"Unknown";
    }
}

#pragma mark - UMARemoteInputEventDelegate

- (BOOL)umaDidPressDownButton:(UMAInputButtonType)button
{
    return YES;
}


- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{
    if (nextPage == 0) {
         return  YES;
    }
    
    if (viewFact == NO) {
        return  YES;
    }
    
    if ([[self getButtonName:button] isEqualToString:@"Back"]) {
//
       
        if (backFactRecommended) {

            [_focusManager setFocusRootView:self.tabBarController.tabBar];
            [_focusManager moveFocus:1];
            inTabbar = YES;
            backFactRecommended = NO;
            
        } else {

            [_focusManager setFocusRootView:self.tableView];
            [_focusManager moveFocus:1];
            backFactRecommended = YES;
            inTabbar = NO;

        }
        
    } else if ([[self getButtonName:button] isEqualToString:@"Main"]) {
        return NO;
        
    } else if ([[self getButtonName:button] isEqualToString:@"VR"]) {
        
        return YES;
    } else if ([[self getButtonName:button] isEqualToString:@"Home"]) {
        return NO;
        
    }
    return YES;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button
{

    return YES;
}

- (BOOL)umaDidDoubleClickButton:(UMAInputButtonType)button
{

    return YES;
}

- (void)umaDidAccelerometerUpdate:(UMAAcceleration)acceleration
{
  
}




#pragma mark - UMAAppDiscoveryDelegate
- (void)didDiscoverySucceed:(NSArray *)appInfo
{
}
#pragma mark - UMAApplicationDelegate

- (UIViewController *)uma:(UMAApplication *)application requestRootViewController:(UIScreen *)screen {
    // This sample does not use this delegate
    return nil;
}

- (void)didDiscoveryFail:(int)reason withMessage:(NSString *)message;
{
   
}
- (void)uma:(UMAApplication *)application didConnectInputDevice:(UMAInputDevice *)device
{

}

- (void)uma:(UMAApplication *)application didDisconnectInputDevice:(UMAInputDevice *)device
{

}

@end

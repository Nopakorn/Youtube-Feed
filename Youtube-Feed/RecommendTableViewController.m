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

static const NSInteger kNumberOfSectionsInTableView = 4;
static NSString *const kRowNum = @"rowNum";
static NSString *const kHeaderText = @"headerText";
static NSString *const kTitleText = @"HID Device Sample";
static const NSInteger kHeightForHeaderInSection = 33;
static const NSTimeInterval kHidDeviceControlTimeout = 5;
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
    
    BOOL didReceivedFromYoutubePlaying;
    BOOL currentPlayingFact;
    NSInteger indexFocus;
    NSInteger indexFocusTabbar;
    NSInteger markHighlightIndex;
}
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    nextPage = true;
    didReceivedFromYoutubePlaying = NO;
    currentPlayingFact = NO;
    markHighlightIndex = 0;
    inTabbar = false;
    self.youtube = [[Youtube alloc] init];
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.recommendYoutube = [[Youtube alloc] init];
    [self getData];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedSettingNotification:)
                                                 name:@"SettingDidSelected" object:nil];
    NSLog(@"view did load recommend");
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Recommended", nil)];
    
    self.recommendedTitle.text = [NSString stringWithFormat:NSLocalizedString(@"Recommended", nil)];
    self.recommendedIconTitle.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubePlayingNotification:)
                                                 name:@"YoutubePlaying" object:nil];
    [self.settingButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Setting", nil)] forState:UIControlStateNormal];
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x3B4C4E);
#pragma setup UMA in ViewDidload in RecommendTableView
//    _inputDevices = [NSMutableArray array];
     _umaApp = [UMAApplication sharedApplication];
     _umaApp.delegate = self;
//    _hidManager = [_umaApp requestHIDManager];
//    
     [_umaApp addViewController:self];
//    
//    //focus
      _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
      [_focusManager setFocusRootView:self.tableView];
      [_focusManager setHidden:NO];
//    [self prepareBlocks];
//    [_hidManager setDisconnectionCallback:_disconnectionBlock];
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
            NSIndexPath *indexPathReload = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
            NSIndexPath *indexPathLastMark = [NSIndexPath indexPathForRow:markHighlightIndex inSection:0];
            NSArray *indexArray = [NSArray arrayWithObjects:indexPathReload, indexPathLastMark, nil];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            //[self.tableView reloadData];
            
        } else {
            didReceivedFromYoutubePlaying = NO;
        }
    }
    NSLog(@"recevied recommend %i",self.recommendPlaying);

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

    NSLog(@"View changing");
    if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        if (portraitFact) {
            if (backFactRecommended) {
                [_focusManager setFocusRootView:self.tableView];
                [_focusManager setHidden:NO];
                if (indexFocus == [self.recommendYoutube.videoIdList count]-1) {
                    [_focusManager moveFocus:indexFocus];
                } else {
                    
                    if (indexFocus == 0) {
                        [_focusManager moveFocus:1];
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
        
        if (landscapeFact) {
            if (backFactRecommended) {
                
                [_focusManager setFocusRootView:self.tableView];
                [_focusManager setHidden:NO];
                if (indexFocus == [self.recommendYoutube.videoIdList count]-1) {
                    [_focusManager moveFocus:indexFocus];
                } else {
                    
                    if (indexFocus == 0) {
                        [_focusManager moveFocus:1];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SettingDidSelected" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    //global objects
    backFactRecommended = YES;
    NSLog(@"view did appear recommend with selected row %ld",(long)self.selectedRow);
    MainTabBarViewController *mainTabbar = (MainTabBarViewController *)self.tabBarController;
    self.recommendYoutube = mainTabbar.recommendYoutube;
    self.genreSelected = mainTabbar.genreSelected;
    indexFocusTabbar = 1;
    portraitFact = YES;
    landscapeFact = YES;
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    if (self.recommendPlaying) {
        didReceivedFromYoutubePlaying = YES;
    } else {
        didReceivedFromYoutubePlaying = NO;
        NSLog(@"not in recommend");
    }
#pragma setup UMA in ViewDidAppear in RecommendTableView
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager setHidden:NO];

    [_focusManager moveFocus:1];
    
    [self.tableView reloadData];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear RecommendedController");
    [_focusManager setHidden:YES];
    //didReceivedFromYoutubePlaying = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//    if (indexPath.row == self.selectedRow) {
//        cell.contentView.backgroundColor = UIColorFromRGB(0xFFCCCC);
//    } else {
//        cell.contentView.backgroundColor = [UIColor whiteColor];
//    }
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
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h + reload_distance) {
        if (nextPage) {
            [self launchReload];
        } else {
            NSLog(@"Its still loading api");
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
        [_focusManager moveFocus:indexFocus];
        //tell viewcontroller to update youtube obj
        //self.delegate recommendTableViewControllerNextPage:self];
    });
    
}



- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    //NSLog(@"focus index %ld distance: %lu diraction: %ld",(long)[_focusManager focusIndex], (unsigned long)distance, (long)direction);
    //NSLog(@"in tabbar %id",backFactRecommended);
    if (nextPage == 0) {
        return YES;
        
    } else {
        
        if (backFactRecommended == 0) {
            //update focus on tabbar
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
            
            
            NSLog(@"in tabbar %ld direction %ld",(long)indexFocusTabbar, (long)direction);
            
        }
        
        indexFocus = [_focusManager focusIndex];
        if (direction == 0) {
            indexFocus+=2;
            if (indexFocus == [self.recommendYoutube.videoIdList count]) {
                //reload data nextPage
                if (nextPage) {
                    indexFocus = 0;
                    [self launchReload];
                    
                } else {
                    NSLog(@"Its still loading api");
                }
            }

        } else {
            if (indexFocus == 0) {
                //reload data nextPage
                if (nextPage) {
                    indexFocus = 0;
                    [self launchReload];
                    
                } else {
                    NSLog(@"Its still loading api");
                }
            }

        }
        
        
        return NO;

    }
    

}
- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY
{
    NSLog(@"at index : %ld",(long)[_focusManager focusIndex]);
    if (backFactRecommended) {
        return YES;
    } else {
        
        if (distanceX == 1 && distanceY == 0) {
            NSLog(@"RIGTH");
            
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
            NSLog(@"LEFT");
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
            NSLog(@"BOTTOM");
            
        }else if (distanceX == 0 && distanceY == -1) {
            NSLog(@"TOP");
            
        }
        return NO;
        
        
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
    NSLog(@"Press Down in Recommended %@",[self getButtonName:button]);
    return YES;
}


- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{
    NSLog(@"Press up in Recommended %id", backFactRecommended);
    if ([[self getButtonName:button] isEqualToString:@"Back"]) {
//
       
        if (backFactRecommended) {
            NSLog(@"in tabbar controller");
            [_focusManager setFocusRootView:self.tabBarController.tabBar];
            [_focusManager moveFocus:1];
            inTabbar = YES;
            backFactRecommended = NO;
            
        } else {
            
            NSLog(@"in main view");
            [_focusManager setFocusRootView:self.tableView];
            [_focusManager moveFocus:1];
            backFactRecommended = YES;
            inTabbar = NO;

        }
        
    } else if ([[self getButtonName:button] isEqualToString:@"Main"]) {
        return NO;
        
    } else if ([[self getButtonName:button] isEqualToString:@"VR"]) {
        
        return YES;
    }
    return YES;
}

- (BOOL)umaDidLongPressButton:(UMAInputButtonType)button
{
    NSLog(@"Long press %@", [self getButtonName:button]);
    return YES;
}

- (BOOL)umaDidDoubleClickButton:(UMAInputButtonType)button
{
    NSLog(@"Double click %@", [self getButtonName:button]);
    return YES;
}

- (void)umaDidAccelerometerUpdate:(UMAAcceleration)acceleration
{
    NSLog(@"Accer x=%f, y=%f, z=%f", acceleration.x, acceleration.y, acceleration.z);
}




#pragma mark - UMAAppDiscoveryDelegate
- (void)didDiscoverySucceed:(NSArray *)appInfo
{
    NSLog(@"didDiscoverySucceed");
    if(appInfo) {
        int i = 0;
        for (UMAApplicationInfo *app in appInfo) {
            NSLog(@"-------------[app(%d)]----------------",i);
            NSLog(@"id    :%@",[app stringProperty:PROP_APP_ID withDefault:@"-"]);
            NSLog(@"name  :%@",[app stringProperty:PROP_APP_NAME withDefault:@"-"]);
            NSLog(@"cname :%@",[app stringProperty:PROP_APP_VENDOR withDefault:@"-"]);
            NSLog(@"text  :%@",[app stringProperty:PROP_APP_DESCRIPTION withDefault:@"-"]);
            NSLog(@"cat   :%@",[app stringProperty:PROP_APP_CATEGORY withDefault:@"-"]);
            NSLog(@"url   :%@",[app stringProperty:PROP_APP_URL withDefault:@"-"]);
            NSLog(@"schema:%@",[app stringProperty:PROP_APP_SCHEMA withDefault:@"-"]);
            NSLog(@"icon  :%@",[app stringProperty:PROP_APP_ICON_URL withDefault:@"-"]);
            NSLog(@"new   :%d",[app integerProperty:PROP_APP_NEW withDefault:-1]);
            NSLog(@"recmt :%d",[app integerProperty:PROP_APP_RECMD withDefault:-1]);
            NSLog(@"date  :%@",[app stringProperty:PROP_APP_DATE withDefault:@"-"]);
            NSLog(@"dev2  :%d",[app integerProperty:PROP_APP_DEV2 withDefault:-1]);
            NSLog(@"drive :%d",[app integerProperty:PROP_APP_DRIVE withDefault:-1]);
            i++;
        }
    }
}
#pragma mark - UMAApplicationDelegate

- (UIViewController *)uma:(UMAApplication *)application requestRootViewController:(UIScreen *)screen {
    // This sample does not use this delegate
    return nil;
}

- (void)didDiscoveryFail:(int)reason withMessage:(NSString *)message;
{
    NSLog(@"app discovery failed. (%@)", message);
}
- (void)uma:(UMAApplication *)application didConnectInputDevice:(UMAInputDevice *)device
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)uma:(UMAApplication *)application didDisconnectInputDevice:(UMAInputDevice *)device
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end

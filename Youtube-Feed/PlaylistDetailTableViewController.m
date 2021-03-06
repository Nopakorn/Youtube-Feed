//
//  PlaylistDetailTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "PlaylistDetailTableViewController.h"
#import "RecommendCustomCell.h"
#import "MainTabBarViewController.h"
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

static NSString *const kSettingsManualConnectionTitle = @"Manual Connection";
static NSString *const kSettingsManualConnectionSubTitle =
@"Be able to select a device which you want to connect.";
static NSString *const kDeviceNone = @"No Name";
static NSString *const kAddressNone = @"No Address";

static NSString *const kRowNum = @"rowNum";
static NSString *const kHeaderText = @"headerText";
static NSString *const kTitleText = @"HID Device Sample";

NSString *const kIsManualConnection = @"is_manual_connection";
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface PlaylistDetailTableViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>

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

@implementation PlaylistDetailTableViewController
{
    NSInteger indexFocus;
    NSInteger indexFocusTabbar;
    BOOL backFactPlaylistDetail;
    BOOL landscapeFact;
    BOOL portraitFact;
    BOOL didReceivedFromYoutubePlaying;
    BOOL viewFact;
    NSInteger directionFocus;
    BOOL scrollKKPTriggered;
    NSInteger markHighlightIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    indexFocusTabbar = 1;
    directionFocus = 0;
    scrollKKPTriggered = YES;
    markHighlightIndex = 0;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubePlayingNotification:)
                                                 name:@"YoutubePlaying" object:nil];
    
    NSString *indexCheck = [NSString stringWithFormat:@"%@",self.playlistIndexCheck];
   
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"updatePlaylistFact"]) {
        self.playlistDetailPlaying = NO;
        
    } else {
        if ([indexCheck isEqualToString:@"NO"]) {
            self.playlistDetailPlaying = NO;
            
        } else {
            NSInteger index = [indexCheck integerValue];
            if (self.playlistIndex == index) {
                self.playlistDetailPlaying = YES;
            } else {
                self.playlistDetailPlaying = NO;
            }
        }

    }
  
   #pragma setup UMA in ViewDidload in PlaylistDetailTableView
    _umaApp = [UMAApplication sharedApplication];
    _umaApp.delegate = self;
    [_umaApp addViewController:self];
    
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager setHidden:NO];

}

- (void)receivedYoutubePlayingNotification:(NSNotification *)notification
{
    Youtube *youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    NSInteger selectedIndex = [[notification.userInfo objectForKey:@"youtubeCurrentPlaying"] integerValue];
    self.playlistDetailPlaying = [[notification.userInfo objectForKey:@"playlistDetailFact"] boolValue];
    NSInteger playlistIndexCheck = [[notification.userInfo objectForKey:@"playlistIndexCheck"] integerValue];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"updatePlaylistFact"]) {
        self.playlistDetailPlaying = NO;
        
    } else {
        if (playlistIndexCheck == self.playlistIndex) {
            if (self.playlistDetailPlaying) {
                if ([self.youtubeVideoList count] == [youtube.videoIdList count]) {
                    if ([[youtube.videoIdList objectAtIndex:selectedIndex] isEqualToString:[[self.youtubeVideoList objectAtIndex:selectedIndex] valueForKey:@"videoId"]]) {
                        self.playlistDetailPlaying = YES;
                        self.selectedRow = selectedIndex;
                        [self.tableView reloadData];

                    }
                }
            } else {
                self.playlistDetailPlaying = NO;
                [self.tableView reloadData];

                
            }
        } else {
            self.playlistDetailPlaying = NO;
            [self.tableView reloadData];
            
        }

    }

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    if (![[self.navigationController viewControllers] containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"YoutubePlaying" object:nil];
         self.playlistDetailPlaying = NO;
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    backFactPlaylistDetail = YES;
    portraitFact = YES;
    landscapeFact = YES;
    viewFact = YES;
    indexFocus = 1;
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 5)];
    navBorder.tag = 99;
    [navBorder setBackgroundColor:UIColorFromRGB(0x4F6366)];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self addingDataToYoutubeObject];

#pragma setup UMA in ViewDidAppear in RecommendTableView
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    
    if ([self.youtubeVideoList count] == 0) {
        [_focusManager setHidden:YES];
    } else {
        [_focusManager setHidden:NO];
        [_focusManager moveFocus:1];    // Give focus to the first icon.
    }
    
    backFactPlaylistDetail = YES;
    //[self.tableView reloadData];
}

- (void)orientationChanged:(NSNotification *)notification
{

    if ([self.youtubeVideoList count] == 0) {
        [_focusManager setHidden:YES];
    } else {
        if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
            if (scrollKKPTriggered) {
                if (portraitFact) {
                    if (backFactPlaylistDetail) {
                        [_focusManager setFocusRootView:self.tableView];
                        [_focusManager setHidden:NO];
                        if (indexFocus == 24) {
                            [_focusManager moveFocus:1];
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
            }
            
        } else {
            if (scrollKKPTriggered) {
                if (landscapeFact) {
                    if (backFactPlaylistDetail) {
                        
                        [_focusManager setFocusRootView:self.tableView];
                        [_focusManager setHidden:NO];
                        if (indexFocus == 24) {
                            [_focusManager moveFocus:1];
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
                [_focusManager setHidden:YES];
            }
            
        }

    }
    
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
}


- (void)addingDataToYoutubeObject
{
    self.youtube = [[Youtube alloc] init];

    for (int i = 0; i < [self.youtubeVideoList count]; i++) {
        YoutubeVideo *youtubeVideo = [self.youtubeVideoList objectAtIndex:i];
        [self.youtube.videoIdList addObject:youtubeVideo.videoId];
        [self.youtube.titleList addObject:youtubeVideo.videoTitle];
        [self.youtube.thumbnailList addObject:youtubeVideo.videoThumbnail];
        [self.youtube.durationList addObject:youtubeVideo.videoDuration];
    }
}

- (NSArray *)youtubeVideoList
{
    if (_youtubeVideoList == nil) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
        _youtubeVideoList = [self.playlist.youtubeVideos.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
        return _youtubeVideoList;
    } else {
        return _youtubeVideoList;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = self.playlist.title;
    [self.tableView reloadData];
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
   
    return [self.youtubeVideoList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"RecommendCustomCell";
    RecommendCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    if (self.playlistDetailPlaying) {
        if (indexPath.row == self.selectedRow) {
            markHighlightIndex = indexPath.row;
            cell.contentView.backgroundColor = UIColorFromRGB(0xFFCCCC);
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }

    YoutubeVideo *youtubeVideoForRow = [self.youtubeVideoList objectAtIndex:indexPath.row];
    cell.name.text = youtubeVideoForRow.videoTitle;
    cell.durationLabel.text = [self durationText:youtubeVideoForRow.videoDuration];
    cell.tag = indexPath.row;
    cell.thumnail.image = nil;
    
    if(youtubeVideoForRow.videoThumbnail != nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:youtubeVideoForRow.videoThumbnail]];
            
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

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"updatePlaylistFact"];
    NSString *selected = [NSString stringWithFormat:@"%lu",(long)indexPath.row];
    [self addingDataToYoutubeObject];

    NSDictionary *userInfo = @{@"youtubeObj": self.youtube,
                               @"selectedIndex": selected,
                               @"playlistIndex": @(self.playlistIndex) };

    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistDetailDidSelected" object:self userInfo:userInfo];
    [self.tabBarController setSelectedIndex:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{

    scrollKKPTriggered = NO;
    [_focusManager setHidden:YES];
    
}

- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    
    if (viewFact == NO) {
        return YES;
    }
    
    if ([self.youtubeVideoList count] == 0) {
        [_focusManager setHidden:YES];
        return YES;
    }
    
    if (backFactPlaylistDetail == 0) {
        scrollKKPTriggered = YES;
        [_focusManager setHidden:NO];
        if (direction == 1) {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 1;
            }
        } else {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 1;
            }
            
            
        }

        if ([_focusManager focusIndex] == 3 && distance == 1 && direction == 0) {
            [_focusManager moveFocus:1];
            
        } else if ([_focusManager focusIndex] == 0 && distance == 1 && direction == 1) {
            [_focusManager moveFocus:4];
            
        } else if ([_focusManager focusIndex] == 3 && distance == 1 && direction == 1) {
            [_focusManager moveFocus:4];
            
        } else if ([_focusManager focusIndex] == 1 && distance == 1 && direction == 0) {
            [_focusManager moveFocus:1];
            
        }
        
    }
    

    indexFocus = [_focusManager focusIndex];
    if (direction == 0) {
        directionFocus = 0;
        indexFocus+=2;
    } else {
        directionFocus = 1;
    }
    
    return NO;
}

- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY
{
    
    if (viewFact == NO) {
        return YES;
    }
    if ([self.youtubeVideoList count] == 0) {
        [_focusManager setHidden:YES];
        return YES;
    }
    indexFocus = [_focusManager focusIndex];
    if (backFactPlaylistDetail) {
        scrollKKPTriggered = YES;
        [_focusManager setHidden:NO];
        if (distanceX == 0 && distanceY == 1) {
            directionFocus = 0;
            indexFocus+=2;
            [_focusManager moveFocus:1 direction:kUMAFocusForward];
        } else if (distanceX == 0 && distanceY == -1) {
            directionFocus = 1;
            [_focusManager moveFocus:1 direction:kUMAFocusBackward];
        }

        return YES;
    } else {
        
        if (distanceX == 1 && distanceY == 0) {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 1;
            }
            
            if ([_focusManager focusIndex] == 1) {
                [_focusManager moveFocus:1];
            } else if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:1];
            }
            
        }else if (distanceX == -1 && distanceY == 0) {
            if ([_focusManager focusIndex] == 0) {
                indexFocusTabbar = 4;
            }else if ([_focusManager focusIndex] == 3) {
                indexFocusTabbar = 2;
            }else if ([_focusManager focusIndex] == 1) {
                indexFocusTabbar = 1;
            }
            
            if ([_focusManager focusIndex] == 0) {
                [_focusManager moveFocus:4];
            } else if ([_focusManager focusIndex] == 3) {
                [_focusManager moveFocus:4];
            }
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
   
    return YES;
}


- (BOOL)umaDidPressUpButton:(UMAInputButtonType)button
{

    if (viewFact == NO) {
        return YES;
    }
    if ([self.youtubeVideoList count] == 0) {
        [_focusManager setHidden:YES];
        if ([[self getButtonName:button] isEqualToString:@"Back"]) {
            [self.navigationController popViewControllerAnimated:YES];
            
        } else if ([[self getButtonName:button] isEqualToString:@"Home"]) {
            return NO;
            
        } else {
            return YES;
        }
    }
    
    if ([[self getButtonName:button] isEqualToString:@"Back"]) {
        //
        [self.navigationController popViewControllerAnimated:YES];

    } else if ([[self getButtonName:button] isEqualToString:@"Main"]) {
        if ([self.youtubeVideoList count] == 0) {
            return YES;
        }
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

    if (viewFact == NO) {
        return YES;
    }
    return NO;
}

- (BOOL)umaDidDoubleClickButton:(UMAInputButtonType)button
{

    return YES;
}

- (void)umaDidAccelerometerUpdate:(UMAAcceleration)acceleration
{
    NSLog(@"Accer x=%f, y=%f, z=%f", acceleration.x, acceleration.y, acceleration.z);
}




#pragma mark - UMAAppDiscoveryDelegate
- (void)didDiscoverySucceed:(NSArray *)appInfo
{

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

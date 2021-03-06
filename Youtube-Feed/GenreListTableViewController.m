//
//  GenreListTableViewController.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/22/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "GenreListTableViewController.h"
#import "RecommendCustomCell.h"
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

@interface GenreListTableViewController ()<UMAFocusManagerDelegate, UMAAppDiscoveryDelegate, UMAApplicationDelegate>

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

@implementation GenreListTableViewController
{
    BOOL nextPage;
    BOOL portraitFact;
    BOOL landscapeFact;
    NSInteger indexFocus;
    NSInteger indexFocusTabbar;
    BOOL backFactGenreList;
    BOOL scrollKKPTriggered;
    NSInteger directionFocus;
    NSInteger markHighlightIndex;
    BOOL viewFact;
    BOOL reloadFact;
    BOOL internetActive;
    BOOL hostActive;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    nextPage = true;
    scrollKKPTriggered = NO;
    reloadFact = NO;
    indexFocusTabbar = 1;
    directionFocus = 0;
    markHighlightIndex = 0;
    hostActive = NO;
    internetActive = NO;
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = self.genreTitle;
   
    NSArray *items = self.genreYoutube.searchResults[@"items"];
    if ([items count] == 0) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Video not found", nil)];
        UILabel *messageLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        messageLb.text = description;
        messageLb.textAlignment = NSTextAlignmentCenter;
        self.tableView.backgroundView = messageLb;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    
    if ([self.genreType isEqualToString:self.searchTerm]) {
        self.genreListPlaying = YES;
        
    } else {
        self.genreListPlaying = NO;
    }

    CGFloat spacing = 5;
    self.backGenreButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.backGenreButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubePlayingNotification:)
                                                 name:@"YoutubePlaying" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedYoutubeReloadNotification:)
                                                 name:@"YoutubeReloadGenreList" object:nil];
    
#pragma setup UMA in ViewDidload in GenreListTableView
    _umaApp = [UMAApplication sharedApplication];
    _umaApp.delegate = self;
    [_umaApp addViewController:self];
    
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager setHidden:NO];
}
- (void)receivedYoutubeReloadNotification:(NSNotification *)notification
{
    self.genreYoutube = [notification.userInfo objectForKey:@"youtubeObj"];
    self.selectedIndex = [[notification.userInfo objectForKey:@"selectedIndex"] integerValue];
    self.genreType = [notification.userInfo objectForKey:@"genreType"];
    [self.tableView reloadData];

}

- (void)receivedYoutubePlayingNotification:(NSNotification *)notification
{
    Youtube *youtube = [notification.userInfo objectForKey:@"youtubeObj"];
    NSInteger selectedIndex = [[notification.userInfo objectForKey:@"youtubeCurrentPlaying"] integerValue];
    self.genreListPlaying = [[notification.userInfo objectForKey:@"genreListFact"] boolValue];
    NSString *genreTypeString = [notification.userInfo objectForKey:@"genreType"];
    
    if (self.genreListPlaying) {
        if ([genreTypeString isEqualToString:self.searchTerm]) {
            if ([youtube.videoIdList count] == [self.genreYoutube.videoIdList count]) {
                self.genreType = genreTypeString;
                self.selectedIndex = selectedIndex;

                if (reloadFact) {
                    [self.tableView reloadData];
                } else {
                    NSIndexPath *indexPathReload = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
                    NSIndexPath *indexPathLastMark = [NSIndexPath indexPathForRow:markHighlightIndex inSection:0];
                    NSArray *indexArray = [NSArray arrayWithObjects:indexPathReload, indexPathLastMark, nil];
                    [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
                }
               
            }
            
        }
    } else {
        
        self.genreListPlaying = NO;
        
        if (reloadFact) {
            [self.tableView reloadData];
        } else {
            NSIndexPath *indexPathLastMark = [NSIndexPath indexPathForRow:markHighlightIndex inSection:0];
            NSArray *indexArray = [NSArray arrayWithObjects:indexPathLastMark, nil];
            [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    if (![[self.navigationController viewControllers] containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"YoutubePlaying" object:nil];
        self.genreListPlaying = NO;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{

    backFactGenreList = YES;
    portraitFact = YES;
    landscapeFact = YES;
    viewFact = YES;
    indexFocus = 1;
    scrollKKPTriggered = YES;
    internetActive = NO;
    hostActive = NO;
    reloadFact = NO;
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
    
#pragma setup UMA in ViewDidAppear in GenreListTableView
    [_umaApp addViewController:self];
    _focusManager = [[UMAApplication sharedApplication] requestFocusManagerForMainScreenWithDelegate:self];
    [_focusManager setFocusRootView:self.tableView];
    [_focusManager moveFocus:1];    // Give focus to the first icon.
    
    if ([self.genreYoutube.videoIdList count] == 0) {
         [_focusManager setHidden:YES];
    } else {
        [_focusManager setHidden:NO];
    }

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
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





- (void)orientationChanged:(NSNotification *)notification
{

    if ([self.genreYoutube.videoIdList count] == 0) {
        [_focusManager setHidden:YES];
    } else {
        if (scrollKKPTriggered) {
            if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
                if (portraitFact) {
                    if (backFactGenreList) {
                        [_focusManager setFocusRootView:self.tableView];
                        [_focusManager setHidden:NO];
                        if (indexFocus == [self.genreYoutube.videoIdList count]-1) {
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
                if (landscapeFact) {
                    if (backFactGenreList) {
                        
                        [_focusManager setFocusRootView:self.tableView];
                        [_focusManager setHidden:NO];
                        if (indexFocus == [self.genreYoutube.videoIdList count]-1) {
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
                
            }
            
        } else {

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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.genreYoutube.videoIdList count] == 0){
        return 0;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.genreYoutube.videoIdList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecommendCustomCell";
    RecommendCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    if ([self.genreYoutube.durationList count] == [self.genreYoutube.videoIdList count]) {
        cell.name.text = [self.genreYoutube.titleList objectAtIndex:indexPath.row];
        cell.tag = indexPath.row;
        NSString *duration = [self.genreYoutube.durationList objectAtIndex:indexPath.row];
        cell.durationLabel.text = [self durationText:duration];
        cell.thumnail.image = nil;
        //
        if(![[self.genreYoutube.thumbnailList objectAtIndex:indexPath.row] isEqualToString:@"nil"]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.genreYoutube.thumbnailList objectAtIndex:indexPath.row]]];
                
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
    
    if (self.genreListPlaying) {
        if (indexPath.row == self.selectedIndex) {
            markHighlightIndex = indexPath.row;
            cell.contentView.backgroundColor = UIColorFromRGB(0xFFCCCC);
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
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
    NSString *selected = [NSString stringWithFormat:@"%lu",(long)self.selectedRow];
    NSDictionary *userInfo = @{ @"youtubeObj": self.genreYoutube,
                               @"selectedIndex": selected,
                               @"genreType":self.searchTerm };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayGenreListDidSelected" object:self userInfo:userInfo];
    [self.tabBarController setSelectedIndex:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    scrollKKPTriggered = NO;   
    [_focusManager setHidden:YES];
    if (![self.genreYoutube.videoIdList count] == 0) {
    
        float reload_distance = 50;
        if(y > h + reload_distance) {
            if (nextPage) {
                reloadFact = YES;
                [self launchReload];
            }
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
    
    [self.genreYoutube getGenreSearchYoutube:self.searchTerm withNextPage:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoIdNextPage)
                                                 name:@"LoadGenreVideoIdNextPage" object:nil];
    
}

- (void)receivedLoadVideoIdNextPage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        self.tableView.tableFooterView = nil;
        reloadFact = NO;
        [self.tableView reloadData];
        nextPage = true;
        
        
        if (scrollKKPTriggered) {
            if (directionFocus == 0) {
                [_focusManager moveFocus:indexFocus+=25];
                indexFocus-=25;
            } else {
                [_focusManager moveFocus:indexFocus];
            }
            
            
        }

        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadGenreVideoIdNextPage" object:nil];
    });
    
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

- (BOOL)umaDidRotateWithDistance:(NSUInteger)distance direction:(UMADialDirection)direction
{
    if ([self.genreYoutube.videoIdList count] == 0) {
        [_focusManager setHidden:YES];
        return YES;
    }
    if (viewFact == NO) {
        return YES;
    }
    
    scrollKKPTriggered = YES;
    [_focusManager setHidden:NO];
    directionFocus = direction;
    
    if (nextPage == 0) {
        return YES;
    } else {

        if (backFactGenreList == 0) {

            if (direction == 1) {
                if ([_focusManager focusIndex] == 0) {
                    indexFocusTabbar = 3;
                }else if ([_focusManager focusIndex] == 1) {
                    indexFocusTabbar = 1;
                }else if ([_focusManager focusIndex] == 2) {
                    indexFocusTabbar = 2;
                }
            } else {
                if ([_focusManager focusIndex] == 0) {
                    indexFocusTabbar = 2;
                }else if ([_focusManager focusIndex] == 1) {
                    indexFocusTabbar = 3;
                }else if ([_focusManager focusIndex] == 2) {
                    indexFocusTabbar = 1;
                }
                
                
            }
            
            if ([_focusManager focusIndex] == 3 && distance == 1 && direction == 0) {
                [_focusManager moveFocus:1];
                
            } else if ([_focusManager focusIndex] == 0 && distance == 1 && direction == 1) {
                [_focusManager moveFocus:3];
                
            }  else if ([_focusManager focusIndex] == 2 && distance == 1 && direction == 0) {
                [_focusManager moveFocus:2];
                
            }
            
        }
        
        indexFocus = [_focusManager focusIndex];
        if (direction == 0) {
            indexFocus+=2;
            directionFocus = 0;
            if (indexFocus == [self.genreYoutube.videoIdList count]) {
                //reload data nextPage
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
        //just test focus move
        
        return NO;
    
    }
   
}

- (BOOL)umaDidTranslateWithDistance:(NSInteger)distanceX distanceY:(NSInteger)distanceY
{
    if ([self.genreYoutube.videoIdList count] == 0) {
        [_focusManager setHidden:YES];
        return YES;
    }
    
    if (viewFact == NO) {
        return YES;
    }

    if (nextPage == 0) {
        [_focusManager lock];
        return  YES;
        
    } else {
        
        if (backFactGenreList) {
            
            [_focusManager unlock];
            scrollKKPTriggered = YES;
            [_focusManager setHidden:NO];
            indexFocus = [_focusManager focusIndex];
            
            if (distanceX == 0 && distanceY == 1) {
               
                [_focusManager moveFocus:1 direction:kUMAFocusForward];
                indexFocus+=2;
                directionFocus = 0;
                if (indexFocus == [self.genreYoutube.videoIdList count]) {
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
                if ([_focusManager focusIndex] == 0) {
                    indexFocusTabbar = 2;
                }else if ([_focusManager focusIndex] == 1) {
                    indexFocusTabbar = 3;
                }else if ([_focusManager focusIndex] == 2) {
                    indexFocusTabbar = 1;
                }
                
                if ([_focusManager focusIndex] == 2) {
                    [_focusManager moveFocus:2];
                    
                } else if ([_focusManager focusIndex] == 3) {
                    [_focusManager moveFocus:1];
                }
            }else if (distanceX == -1 && distanceY == 0) {

                if ([_focusManager focusIndex] == 0) {
                    indexFocusTabbar = 3;
                }else if ([_focusManager focusIndex] == 1) {
                    indexFocusTabbar = 1;
                }else if ([_focusManager focusIndex] == 2) {
                    indexFocusTabbar = 2;
                }
                
                if ([_focusManager focusIndex] == 0) {
                    [_focusManager moveFocus:3];
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
    if (viewFact == NO) {
        return YES;
    }
    if ([self.genreYoutube.videoIdList count] == 0) {
        if ([[self getButtonName:button] isEqualToString:@"Back"]) {
            [self.navigationController popViewControllerAnimated:YES];
            
        } else if ([[self getButtonName:button] isEqualToString:@"Home"]) {
            return NO;
            
        } else {
            [_focusManager setHidden:YES];
            return YES;

        }
    }
    
    if ([[self getButtonName:button] isEqualToString:@"Back"]) {
        [self.navigationController popViewControllerAnimated:YES];

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
;
}


 
@end

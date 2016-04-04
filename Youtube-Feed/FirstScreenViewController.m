//
//  FirstScreenViewController.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/30/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "FirstScreenViewController.h"
#import "MainTabBarViewController.h"

@interface FirstScreenViewController ()

@end

@implementation FirstScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.youtube = [[Youtube alloc] init];
    self.genreSelected = [[NSMutableArray alloc] initWithCapacity:10];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.loadingLabel.hidden = YES;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"genreSelectedFact"]) {
        
                NSString *saveGenre = [[NSUserDefaults standardUserDefaults] stringForKey:@"genreSelectedString"];
                NSLog(@"YES genre is selected %@",saveGenre);
                NSArray *stringSeparated = [saveGenre componentsSeparatedByString:@"+"];
                self.genreSelected = [NSMutableArray arrayWithArray:stringSeparated];
                [self callSearchSecondTime:saveGenre];
        //[self performSegueWithIdentifier:@"SettingView" sender:@0];
    } else {

        [self performSegueWithIdentifier:@"SettingView" sender:@0];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)callSearchSecondTime:(NSString *)saveGenre
{
    [self.youtube getRecommendSearchYoutube:saveGenre withNextPage:NO];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
     self.loadingLabel.hidden = NO;
    //[self presentViewController:alert animated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoId" object:nil];
    
}

- (void)callSearchFirstTime:(NSString *)saveGenre
{
    [self.youtube getRecommendSearchYoutube:saveGenre withNextPage:NO];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
     self.loadingLabel.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoId" object:nil];
    
}


- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        NSLog(@"perform");
        [self performSegueWithIdentifier:@"SubmitToTabbarController" sender:@0];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SubmitToTabbarController"]){
        NSNumber *indexShow = @0;
        NSLog(@"tabbar segue");
        MainTabBarViewController *dest = segue.destinationViewController;
        dest.youtube = self.youtube;
        dest.recommendYoutube = self.youtube;
        dest.genreSelected = self.genreSelected;
        [dest setSelectedIndex:indexShow.unsignedIntegerValue];

    } else if ([segue.identifier isEqualToString:@"SettingView"]) {
        FirstSettingTableViewController *newVC = segue.destinationViewController;
        newVC.delegate = self;
        [FirstScreenViewController setPresentationStyleForSelfController:self presentingController:newVC];
        
    }
}

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

- (void)firstSettingTableViewControllerDidSelected:(FirstSettingTableViewController *)firstSettingViewController
{
    
    self.genreSelected = firstSettingViewController.genreSelected;
    NSString *genreSelectedString = @"";
    for(int i = 0 ; i < [self.genreSelected count] ; i++){
        genreSelectedString = [NSString stringWithFormat:@"%@ %@", genreSelectedString, [self.genreSelected objectAtIndex:i]];
    }
    genreSelectedString = [genreSelectedString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [self callSearchFirstTime:genreSelectedString];
}
@end

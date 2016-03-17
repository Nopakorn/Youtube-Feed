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
#import "AppDelegate.h"

@interface RecommendTableViewController ()

@end

@implementation RecommendTableViewController

@synthesize delegate = _delegate;
//@synthesize selectedRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.youtube = [[Youtube alloc] init];
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.recommendYoutube = [[Youtube alloc] init];
    [self getData];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)getData
{
    MainTabBarViewController *mainTabbar = (MainTabBarViewController *)self.tabBarController;
    self.recommendYoutube = mainTabbar.recommendYoutube;
//    if(self.youtube.videoIdList != 0) {
//        for (int i = 0; i < [self.youtube.videoIdList count]; i++) {
//            [self.recommendYoutube.videoIdList addObject:[self.youtube.videoIdList objectAtIndex:i]];
//            [self.recommendYoutube.titleList addObject:[self.youtube.titleList objectAtIndex:i]];
//            [self.recommendYoutube.thumbnailList addObject:[self.youtube.thumbnailList objectAtIndex:i]];
//        }
//        
//    }else {
//        NSLog(@"youtube nil");
//    }
}


- (void)viewDidAppear:(BOOL)animated
{
    //global objects
    MainTabBarViewController *mainTabbar = (MainTabBarViewController *)self.tabBarController;
    self.recommendYoutube = mainTabbar.recommendYoutube;
     NSLog(@"view appear recommendTable %lu",(unsigned long)[self.recommendYoutube.titleList count]);
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
    
    cell.name.text = [self.recommendYoutube.titleList objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
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
    return 80;
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


@end

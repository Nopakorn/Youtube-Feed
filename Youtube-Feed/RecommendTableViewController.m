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


@interface RecommendTableViewController ()

@end

@implementation RecommendTableViewController

@synthesize delegate = _delegate;
//@synthesize selectedRow;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    [self getData];
}

- (void)getData
{
    MainTabBarViewController *mainTabbar = (MainTabBarViewController *)self.tabBarController;
    self.youtube = mainTabbar.youtube;    
    NSLog(@"received youtube obj %lu",(unsigned long)[self.youtube.videoIdList count]);
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

    return [self.youtube.videoIdList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecommendCustomCell";
    RecommendCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.name.text = [self.youtube.titleList objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    cell.thumnail.image = nil;
//    
    if([self.youtube.thumbnailList objectAtIndex:indexPath.row] != [NSNull null]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.youtube.thumbnailList objectAtIndex:indexPath.row]]];
                
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

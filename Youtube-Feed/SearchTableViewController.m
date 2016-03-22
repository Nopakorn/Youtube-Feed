//
//  SearchTableViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/16/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "SearchTableViewController.h"
#import "RecommendCustomCell.h"
#import "MainTabBarViewController.h"

@interface SearchTableViewController ()

@end

@implementation SearchTableViewController
{
    BOOL nextPage;
}
@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search from Youtube";
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//    [self.view addGestureRecognizer:tap];
    nextPage = true;
    self.youtube = [[Youtube alloc] init];
    self.searchYoutube = [[Youtube alloc] init];
    
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    if([self.searchYoutube.videoIdList count] == 0 ) {
        return 0;
    }else {
        return [self.searchYoutube.videoIdList count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecommendCustomCell";
    RecommendCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecommendCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.name.text = [self.searchYoutube.titleList objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    cell.thumnail.image = nil;
    //
    if([self.searchYoutube.thumbnailList objectAtIndex:indexPath.row] != [NSNull null]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.searchYoutube.thumbnailList objectAtIndex:indexPath.row]]];
            
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
    
    
//    if (indexPath.row == [self.searchYoutube.videoIdList count]-1) {
//        [self launchReload];
//    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didselect row");
    self.selectedRow = indexPath.row;
    [self.delegate searchTableViewControllerDidSelected:self];
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
    
    [self.searchYoutube callSearchNextPage:self.searchText];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoIdNextPage)
                                                 name:@"LoadVideoIdFromSearchNextPage" object:nil];
   
}




- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
     self.searchBar.text = @"";
     self.searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //when text changing
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        [self.tableView reloadData];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
    

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchYoutube.titleList removeAllObjects];
    [self.searchYoutube.videoIdList removeAllObjects];
    [self.searchYoutube.thumbnailList removeAllObjects];
    [self.tableView reloadData];
    
    self.searchText = searchBar.text;
    [self.searchYoutube callSearchByText:searchBar.text];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.view.center.x, 85.5);
    spinner.color = [UIColor blackColor];
    [self.tableView addSubview:spinner];
    [spinner startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLoadVideoId)
                                                 name:@"LoadVideoIdFromSearch" object:nil];
}
- (void)receivedLoadVideoId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        [self.tableView reloadData];
        [self.searchBar resignFirstResponder];
        self.searchBar.showsCancelButton = NO;
    });

}

- (void)receivedLoadVideoIdNextPage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        self.tableView.tableFooterView = nil;
        [self.tableView reloadData];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.searchYoutube.videoIdList count]-26 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        nextPage = true;
    });

}

@end

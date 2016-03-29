//
//  GenreListTableViewController.m
//  KKP-Movie
//
//  Created by Siam System Deverlopment on 3/22/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "GenreListTableViewController.h"
#import "RecommendCustomCell.h"

@interface GenreListTableViewController ()

@end

@implementation GenreListTableViewController
{
    BOOL nextPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    nextPage = true;
    self.imageData = [[NSMutableArray alloc] initWithCapacity:10];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = self.searchTerm;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"View did disappear");

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
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
    
    cell.name.text = [self.genreYoutube.titleList objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    NSString *duration = [self.genreYoutube.durationList objectAtIndex:indexPath.row];
    cell.durationLabel.text = [self durationText:duration];
    cell.thumnail.image = nil;
    //
    if([self.genreYoutube.thumbnailList objectAtIndex:indexPath.row] != [NSNull null]){
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
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
    NSString *selected = [NSString stringWithFormat:@"%lu",self.selectedRow];
    NSDictionary *userInfo = @{@"youtubeObj": self.genreYoutube,
                               @"selectedIndex": selected};
    NSLog(@"post playlistdetail");
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
        [self.tableView reloadData];
        nextPage = true;
        //tell viewcontroller to update youtube obj
        //[self.delegate recommendTableViewControllerNextPage:self];
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
    
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    
}

 
@end

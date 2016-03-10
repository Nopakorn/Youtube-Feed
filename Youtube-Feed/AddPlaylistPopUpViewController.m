//
//  AddPlaylistPopUpViewController.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/10/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "AddPlaylistPopUpViewController.h"
#import "PlaylistPopUpCustomCell.h"

@interface AddPlaylistPopUpViewController ()

@end

@implementation AddPlaylistPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playlistTableView.delegate = self;
    self.playlistTableView.dataSource = self;
    self.playlistTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self createPlaylist];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)createPlaylist
{
    //should be data from user
    self.playlist = [[NSMutableArray alloc] initWithObjects:@"My Music 1", @"My Music 2", @"My Music 3", nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playlist count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PlaylistPopUpCustomCell";
    PlaylistPopUpCustomCell *cell =[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PlaylistPopUpCustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.name.text = [self.playlist objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"object select at %@", [self.playlist objectAtIndex:indexPath.row] );
}


- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)okButtonPressed:(id)sender
{
   
}

@end

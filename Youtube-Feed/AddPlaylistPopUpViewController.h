//
//  AddPlaylistPopUpViewController.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/10/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "Youtube.h"


@interface AddPlaylistPopUpViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, retain) NSMutableArray *playlist;
@property(strong, nonatomic) Youtube *youtube;

@property(weak, nonatomic) IBOutlet UITableView *playlistTableView;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *okButton;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)okButtonPressed:(id)sender;

@end

//
//  SettingTableViewController.h
//  Youtube-Feed
//
//  Created by guild on 3/8/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Youtube.h"

@interface SettingTableViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger selectedRow;
}

@property (nonatomic, retain) NSMutableArray *selectedType;
@property (nonatomic, retain) NSMutableArray *genreList;
@property (nonatomic, retain) NSMutableArray *genreSelected;

@property(weak, nonatomic) IBOutlet UITableView *settingTableView;
@property(weak,nonatomic) IBOutlet UIButton  *submitButton;

@end

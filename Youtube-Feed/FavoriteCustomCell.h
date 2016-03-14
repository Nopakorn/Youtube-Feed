//
//  FavoriteCustomCell.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/14/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteCustomCell : UITableViewCell

@property(weak,nonatomic) IBOutlet UILabel *name;
@property(weak,nonatomic) IBOutlet UIImageView *thumnail;
@property(weak,nonatomic) IBOutlet UIImageView *favoriteIcon;

@end

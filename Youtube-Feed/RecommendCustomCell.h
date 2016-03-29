//
//  RecommendCustomCell.h
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/11/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendCustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@property(weak,nonatomic) IBOutlet UILabel *name;
@property(weak,nonatomic) IBOutlet UIImageView *thumnail;
@end

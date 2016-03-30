//
//  RecommendCustomCell.m
//  Youtube-Feed
//
//  Created by Siam System Deverlopment on 3/11/2559 BE.
//  Copyright © 2559 guild. All rights reserved.
//

#import "RecommendCustomCell.h"

@implementation RecommendCustomCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews
{
    [super layoutSubviews];
//    self.thumnail.contentMode = UIViewContentModeScaleAspectFill;
//    self.thumnail.clipsToBounds = YES;
//    self.thumnail.frame = CGRectMake(self.thumnail.frame.origin.x, self.thumnail.frame.origin.y, 100, 50);
    self.durationLabel.adjustsFontSizeToFitWidth = YES;
}

@end

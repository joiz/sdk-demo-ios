//
//  HomeCompetitionCell.m
//  joizSDKDemo
//
//  Created by George Ilies on 01.08.2016.
//  Copyright © 2016 Reea. All rights reserved.
//

#import "HomeCompetitionCell.h"
#import "Consts.h"
#import "Defs.h"
#import "Haneke.h"

@implementation HomeCompetitionCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureCell:(NSDictionary *) cellData {
    if ([self respondsToSelector:@selector(preservesSuperviewLayoutMargins)]){
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
    }
    
    self.separatorInset = UIEdgeInsetsZero;
    
    // TITLE
    self.titleLabel.text = cellData[kArticleModelFieldTitle];
    
    // IMAGE
    NSString *imageUrl = cellData[kArticleModelFieldImageUrl];
    if ([imageUrl length]) {
        if ([imageUrl rangeOfString:@"http"].location == NSNotFound) {
            imageUrl = absImageUrl(@"cmf_319_179", imageUrl);
        }
    }
    
    __weak HomeCompetitionCell *weakSelf = self;
    //    debug(@"cell.contentStatus: %ld", self.contentStatus); 
    
        
    // DESCRIPTION
    NSString *desc = cellData[kArticleModelFieldDescription];
    self.descriptionLabel.text = desc;
        
    if ([imageUrl length]) {
        [self.cellImage hnk_setImageFromURL:[NSURL URLWithString:imageUrl]
                                       placeholder:[UIImage imageNamed:@"no_image.jpg"]
                                           success:^(UIImage *image) {
                                               weakSelf.cellImage.image = image;
                                           } failure:^(NSError *error) {
                                           }];
    } else {
        self.cellImage.image = [UIImage imageNamed:@"joizno_image.jpglogo.jpg"];
    }
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

-(void) prepareForReuse {
    [super prepareForReuse];
    
    self.titleLabel.text = @"";
    self.descriptionLabel.text = @"";
    self.cellImage.image = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

//
//  HomeCompetitionCell.h
//  joizSDKDemo
//
//  Created by George Ilies on 01.08.2016.
//  Copyright © 2016 Reea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCompetitionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;

-(void) configureCell:(NSDictionary *) cellData;

@end

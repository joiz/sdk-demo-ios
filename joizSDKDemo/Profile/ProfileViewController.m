//
//  ProfileViewController.m
//  joizSDKDemo
//
//  Created by George Ilies on 13.07.2015.
//  Copyright (c) 2015 Reea. All rights reserved.
//

#import "Defs.h"
#import "ProfileViewController.h"
#import <JoizSDK/JoizSDKLoginManager.h>
#import <joizSDK/JoizSDKProfile.h>
#import "Haneke.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextView *profileText;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    JoizSDKProfile *ownProfile  = [JoizSDKLoginManager shared].loginSettings.ownProfileData;
    self.profileText.text = [NSString stringWithFormat:@"username: %@\nnickname: %@\nemail: %@\nfirst name: %@\nlast name: %@\ncity: %@\n", 
                                                        ownProfile.username,
                                                        ownProfile.nickname,
                                                        ownProfile.email,
                                                        ownProfile.firstname,
                                                        ownProfile.lastname,
                                                        ownProfile.city
                            ];
    
    __weak ProfileViewController *weakSelf = self;
    [self.profileImageView hnk_setImageFromURL:[NSURL URLWithString:absImageUrl(@"600_600", ownProfile.imageURLString)] placeholder:[UIImage imageNamed:@"user.png"] success:^(UIImage *image) {
        weakSelf.profileImageView.image = image;
    } failure:^(NSError *error) {
        weakSelf.profileImageView.image = [UIImage imageNamed:@"user.png"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

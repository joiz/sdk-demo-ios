//
//  RootViewController.m
//  joizSDKDemo
//
//  Created by George Ilies on 13.07.2015.
//  Copyright (c) 2015 Reea. All rights reserved.
//

#import "RootViewController.h"
#import "AuthViewController.h"
#import <joizSDK/JoizSDKRedButtonProtocol.h>
#import <joizSDK/JoizSDKRedButtonManager.h>
#import <JoizSDK/JoizSDKLoginManager.h>
#import <joizSDK/JoizSDKAppSettings.h>
#import <joizSDK/UIColor+JZAdditions.h>
#import <joizSDK/JoizSocketManager.h>
#import "ProfileViewController.h"
#import "CompetitionsViewController.h"


@interface RootViewController ()

@property (nonatomic, strong) UIButton *redButton;
-(void) addRedButtonToNav;
@property CGFloat currentRed;
@property NSInteger direction;

//@property SEL queuedSelector;

@property (nonatomic, strong) NSTimer *redbuttonPulseTimer;

@end

#define kAuthenticationButton       1
#define kAddNavReButton             2
#define kGoToProfileScreen          3
#define kCompetitionsScreen         4
#define kScreenReButton             5

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

-(void) viewWillAppear:(BOOL)animated {
    NSLog(@"nav.subviews: %@", self.navigationController.view.subviews);
    
    UIButton *profileButton = (UIButton *) [self.view viewWithTag:kGoToProfileScreen];
    if ([[JoizSDKLoginManager shared] isLoggedIn]) {
        profileButton.userInteractionEnabled = YES;
        profileButton.titleLabel.alpha = 1.0f;
    } else {
        profileButton.userInteractionEnabled = NO;
        profileButton.titleLabel.alpha = 0.7f;                
    }
    
    [super viewWillAppear:animated];
}

-(IBAction)onButton:(id)sender {
    UIButton *tappedButton = (UIButton *) sender;
    
    switch (tappedButton.tag) {
        case kAuthenticationButton: {
            //push to auth
            [self requestUserToAuthenticate];
        }
            break;
        /*
         This will register the listener for leadVideo Broadcast from nodeJs
         */
        case kAddNavReButton: {
//            tappedButton.enabled = NO;
            //there must be a better way ... :)), but this is a demo
            if (![[JoizSDKRedButtonManager singleton] delegate]) {
                [self addRedButtonToNav];
                
                [JoizSDKRedButtonManager managerWithDelegate:(id<JoizSDKRedButtonDelegate>) self];
                [[JoizSocketManager shared] getLiveStreamInformations];

                [[JoizSDKRedButtonManager singleton] setupRedButtonWithData:@{@"redButton": self.redButton, @"navBarView" : self.navigationController.navigationBar}];
                
                [[[UIAlertView alloc] initWithTitle:@"Info" message:@"When the appropriate broadcast packet will be received, the red button will be shown automatically" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
            break; 
        case kGoToProfileScreen: {
            ProfileViewController *pc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewControllerIdentifier"];
            [self.navigationController pushViewController:pc animated:YES];
            pc = nil;
        }
            break;
            
        case kCompetitionsScreen: {
            CompetitionsViewController *cc = [self.storyboard instantiateViewControllerWithIdentifier:@"CompetitionsViewControllerIdentifier"];
            [self.navigationController pushViewController:cc animated:YES];
            cc =nil;
        }
            break;
        default:
            break;
    }
}

-(void) addRedButtonToNav {
    if ([[JoizSDKRedButtonManager singleton] redButtonIsShowing]) {
        return;
    }
    
    UIButton *rb = [UIButton buttonWithType:UIButtonTypeCustom];
    rb.translatesAutoresizingMaskIntoConstraints = NO;
//    rb.backgroundColor = [UIColor redColor];
    rb.alpha = 0.0;
    rb.userInteractionEnabled = NO;
    [rb setTitle:@"Red button" forState:UIControlStateNormal];

    [self.navigationController.navigationBar addSubview:rb];
    
//    rb.frame = CGRectMake(20, 0, 300, 44);
//    return;
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:rb
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.navigationController.navigationBar
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    NSLayoutConstraint *constraintLeft = [NSLayoutConstraint constraintWithItem:rb
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.navigationController.navigationBar
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1.0
                                                                         constant:45.0];
    
    NSLayoutConstraint *constraintRight = [NSLayoutConstraint constraintWithItem:rb
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.navigationController.navigationBar
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-45.0];
    
    NSLayoutConstraint *constraintHeight = [NSLayoutConstraint constraintWithItem:rb
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.navigationController.navigationBar
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1.0
                                                                        constant:0.0];
    
    
    [self.navigationController.view addConstraints:[NSArray arrayWithObjects:constraintTop, constraintLeft, constraintRight, constraintHeight, nil]];
    
    constraintTop = nil;
    constraintLeft = nil;
    constraintRight = nil;
    constraintHeight = nil;
    
    self.redButton = rb;
    rb = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)redYin {
    
    CGFloat interval = 9.0;
    if ( self.currentRed <= 100.0 ) {
        self.direction = 1;
    }
    if ( self.currentRed >= 226.0 ) {
        self.direction = 0;
    }
    
    if ( self.direction == 0 ) {
        self.currentRed -= interval;
    } else {
        self.currentRed += interval;
    }

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRGB:@[ [NSNumber numberWithFloat:self.currentRed],
                                                             @14.0, @18.0, @1.0 ]];
    
    self.redbuttonPulseTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                target:self
                                                              selector:@selector(redYin)
                                                              userInfo:nil
                                                               repeats:NO];
    
}

#pragma mark JoizSDKRedButtonDelegate
-(NSDictionary *) showRedButton {

    NSDictionary *queuedDetails =  @{
                                     @"title" : [self.navigationItem.title length] ? self.navigationItem.title : @"Root",
                                     @"color" : self.navigationController.navigationBar.barTintColor ? self.navigationController.navigationBar.barTintColor : [UIColor whiteColor],
                                    };
    
    self.redButton.alpha = 1.0;
    self.redButton.userInteractionEnabled = YES;
    
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationItem.title = @"";
//    self.bar.controllerTitleLabel.text = JZLocalizedString(@"redbutton.title", @"");
    
    if ( self.redbuttonPulseTimer ) {
        if ( [self.redbuttonPulseTimer isValid] ) {
            [self.redbuttonPulseTimer invalidate];
        }
        self.redbuttonPulseTimer = nil;
    }
    
    __weak RootViewController *weakSelf = self;
    [UIView animateWithDuration:0.44 animations:^{
        weakSelf.navigationController.navigationBar.barTintColor = [UIColor jz_colorWithHex:0xEE1D0B];
    } completion:^(BOOL finished) {
        weakSelf.currentRed = 226.0f;
        [weakSelf redYin];
    }];
    
    return queuedDetails;
}

-(void) hideRedButton:(NSDictionary *) restoreDetails {
    self.redButton.alpha = 0.0;
    
//    self.bar.view.userInteractionEnabled = YES;
    self.redButton.userInteractionEnabled = NO;

    if ( self.redbuttonPulseTimer ) {
        if ( [self.redbuttonPulseTimer isValid] ) {
            [self.redbuttonPulseTimer invalidate];
        }
        
        self.redbuttonPulseTimer = nil;
    }
    
    if ([restoreDetails objectForKey:@"color"]) {
        self.navigationController.navigationBar.barTintColor = [restoreDetails objectForKey:@"color"];
    }
    
    if ([restoreDetails objectForKey:@"title"]) {
        self.navigationItem.title = [restoreDetails objectForKey:@"title"];
    }
}

-(void) redButtonDataReceived {
    
}

-(void) requestUserToAuthenticate {
    if ([self.navigationController.topViewController isKindOfClass:[AuthViewController class]]) {
        return;
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AuthViewController *authObj = [mainStoryboard instantiateViewControllerWithIdentifier:@"AuthViewControllerIdentifier"];
    [self.navigationController pushViewController:authObj animated:YES];
    authObj = nil;
}

-(void) presentRedButtonScreen:(UIViewController *) screen {
    NSLog(@"navBar: %d", self.navigationController.navigationBarHidden);
    [self.navigationController pushViewController:screen animated:YES];
    
    screen = nil;
}

-(void) removeRedButtonScreen {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

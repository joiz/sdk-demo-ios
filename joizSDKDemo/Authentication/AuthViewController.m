//
//  AuthViewController.m
//  joizSDKDemo
//
//  Created by George Ilies on 13.07.2015.
//  Copyright (c) 2015 Reea. All rights reserved.
//

#import "AuthViewController.h"
#import <joizSDK/JoizSDKLoginManager.h>
#import <joizSDK/JZCloakViewController.h>
#import <joizSDK/JoizSDKLoginProtocol.h>
#import "UIAlertView+BlocksKit.h"
#import <joizSDK/JoizSDKProfile.h>
#import <joizSDK/JoizSDKRedButtonManager.h>
#import <joizSDK/JoizSDKAppSettings.h>
#import <joizSDK/JoizSDKUtilities.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "UIButton+Layout.h"


#define kEnterAsGuestButtonTag  555
#define kShowForgotButtonTag    554
#define kAuthenticateButtonTag  553

#define kForgotPasswordButtonTag        560
#define kCancelForgotPasswordButtonTag  561

#define kCreateAccountButtonTag         570
#define kCancelCreateAccountButtonTag   571
#define kTCButtonTag                    572

@interface AuthViewController () <JoizSDKLoginDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *parentContainerScrollView;
//currently presented section of the login screen i.e: social login, create account, confirmation or pass reset
@property NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *uiStack;
//will tell if various views of the login screen were ever intialized
@property (nonatomic, strong) NSMutableDictionary *initializedTable;

//will hold login auth/user creation section
@property (nonatomic, strong) IBOutlet UIView *loginContainerView;
//will hold login register & legal info
@property (nonatomic, strong) IBOutlet UIView *registerLegalContainerView;
//will hold login account/code confirmation
@property (nonatomic, strong) IBOutlet UIView *confirmationView;
@property (nonatomic, strong) IBOutlet UILabel *confirmationLabel;
//will hold login forgot password section
@property (nonatomic, strong) IBOutlet UIView *forgotPasswordContainerView;
//will hold login password reset section
@property (nonatomic, strong) IBOutlet UIView *resetPasswordContainerView;
@property (nonatomic, weak) UIView *currentScreen;

-(void) setupAndShowScreen:(LoginScreenType) screen;
-(IBAction) onButtonTapped:(id) sender;

@end

@implementation AuthViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

    self.initializedTable = [NSMutableDictionary dictionaryWithCapacity:3];
    [self setupAndShowScreen:LoginScreenTypeSocialLogin];
    //set login manager delegate to self
    [[JoizSDKLoginManager shared] setDelegate:self];
    
    UILabel *userName = (UILabel *) [self.view viewWithTag:10];
    UIButton *authButton = (UIButton *) [self.view viewWithTag:20];
    
    if ([[JoizSDKLoginManager shared] isLoggedIn]) {      
        userName.text = [[JoizSDKLoginManager shared].loginSettings.ownProfileData email];
        ((UITextField *)[self.view viewWithTag:1]).enabled = NO;             
        ((UITextField *)[self.view viewWithTag:2]).enabled = NO;  
        
        [authButton setTitle:@"Logout" forState:UIControlStateNormal];        
    } else {
        userName.text = @"Guest";        
        [authButton setTitle:@"Authenticate" forState:UIControlStateNormal];
    }

    if ([[JoizSDKRedButtonManager singleton] redButtonIsShowing]) {
        self.navigationItem.title = @"";
    }
}

-(void) setupAndShowScreen:(LoginScreenType) screen {
    switch (screen) {
        case LoginScreenTypeSocialLogin: {
            [self setupSocialLoginScreen];
            [self showScreen:self.loginContainerView];
        }
            break;
        case LoginScreenTypeForgotPassword:
            [self setupForgotPasswordScreen];
            [self showScreen:self.forgotPasswordContainerView];
            break;
        case LoginScreenTypeRegisterLegal:
            [self setupRegistrationLegalScreen];
            [self showScreen:self.registerLegalContainerView];
            break;
//        case LoginScreenTypeRegisterCodeConfirm: {
//            [self setupConfirmationScreen];
//            [self showScreen:self.confirmationView];
//        }
//            break;
//        case LoginScreenTypeRegisterInfo:
//        case LoginScreenTypeRegisterActivation:
//        case LoginScreenTypeUnknown:
//            break;
//        case LoginScreenTypeResetPassword : {
//            [self setupResetPasswordScreen];
//            [self showScreen:self.resetPasswordContainerView];
//        }
//            break;
        default:
            break;
    }
}

#pragma mark screens setup
-(void) setupSocialLoginScreen {
    self.loginContainerView.hidden = NO;
    
    if ( [self.initializedTable objectForKey:[NSNumber numberWithInteger:LoginScreenTypeSocialLogin]] ) {
        return;
    }
    self.loginContainerView.tag = 11111;
    self.loginContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.initializedTable setObject:@1 forKey:[NSNumber numberWithInteger:LoginScreenTypeSocialLogin]];
       
        
    NSArray *constraintW = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[_loginContainerView(==%f)]", self.view.frame.size.width]
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_loginContainerView)];  
    NSArray *constraintH = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_loginContainerView(==%f)]", self.view.frame.size.height]
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_loginContainerView)];
    
    [self.loginContainerView addConstraints:constraintW];
    [self.loginContainerView addConstraints:constraintH];
    
    constraintW = nil;
    constraintH = nil;
    
    UIButton *guestButton = (UIButton *) [_loginContainerView viewWithTag:kEnterAsGuestButtonTag];
    [guestButton addBorderWithColor:[UIColor grayColor]];
    if ([[JoizSDKAppSettings singleton] guestAccessAllowed] > 0) {
        
    } else {
        guestButton.enabled = NO;
        guestButton.hidden = YES;
    }
    
    UIButton *authenticateButton = (UIButton *) [self.loginContainerView viewWithTag:kAuthenticateButtonTag];
    [authenticateButton addBorderWithColor:[UIColor grayColor]];
    
    [self.loginContainerView setNeedsLayout];
}

- (void)setupForgotPasswordScreen {
    if ( [self.initializedTable objectForKey:[NSNumber numberWithInteger:LoginScreenTypeForgotPassword]] ) {
        return;
    }
    
    [self.initializedTable setObject:@1 forKey:[NSNumber numberWithInteger:LoginScreenTypeForgotPassword]];
    
    self.forgotPasswordContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *constraintW = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[_forgotPasswordContainerView(==%f)]", self.view.frame.size.width]
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_forgotPasswordContainerView)];  
    NSArray *constraintH = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[_forgotPasswordContainerView(==%f)]", self.view.frame.size.height]
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_forgotPasswordContainerView)];
    
    [self.forgotPasswordContainerView addConstraints:constraintW];
    [self.forgotPasswordContainerView addConstraints:constraintH];
    
    constraintW = nil;
    constraintH = nil;
    
    UIButton *forgotButton = (UIButton *) [self.forgotPasswordContainerView viewWithTag:kForgotPasswordButtonTag];
    [forgotButton addBorderWithColor:[UIColor grayColor]];

    UIButton *cancelButton = (UIButton *) [self.forgotPasswordContainerView viewWithTag:kCancelForgotPasswordButtonTag];
    [cancelButton addBorderWithColor:[UIColor grayColor]];
    
    [self.forgotPasswordContainerView setNeedsLayout];
}

- (void)setupRegistrationLegalScreen {
    if ( [self.initializedTable objectForKey:[NSNumber numberWithInteger:LoginScreenTypeRegisterLegal]] ) {
        return;
    }
    
    self.registerLegalContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.initializedTable setObject:@1
                              forKey:[NSNumber numberWithInteger:LoginScreenTypeRegisterLegal]];
    
    
    NSString *emailOrPhone = [[[JoizSDKLoginManager shared] queuedUserCredentials] objectForKey:@"email"];
    NSAssert([emailOrPhone length], @"No email in registration screen ?");    
    BOOL isEmail = NO;
    if ([emailOrPhone rangeOfString:@"@"].location != NSNotFound) {
        isEmail = YES;
    }
    
    NSString *firstPart = JZLocalizedString(@"login.accountByPhone", @"");
    if (isEmail) {
        firstPart = JZLocalizedString(@"login.accountByEmail", @"");
    }
    
    NSString *total = [NSString stringWithFormat:@"%@ %@",firstPart,emailOrPhone];
    NSMutableAttributedString *totalAttr = [[NSMutableAttributedString alloc]
                                            initWithString:total
                                            attributes:@{}];
    [totalAttr addAttribute:NSFontAttributeName
                      value:[UIFont jzFontWithName:fontName size:[fontSize floatValue]]
                      range:NSMakeRange(firstPart.length, [emailOrPhone length])];
    self.creatingEmailLabel.attributedText = totalAttr;
    
    
    
    [self.createButton standardizeWithData:crbuttonsProps];
    crbuttonsProps = nil;
    
    [self.cancelButton standardizeWithData:cancelButtonProps];
    [_cancelButton addTarget:self action:@selector(navigateBackward) forControlEvents:UIControlEventTouchUpInside];
    cancelButtonProps = nil; 
    
    //    [self.privacyButton underlinedLinkButtonWithText:JZLocalizedString(@"login.privacypolicy", @"")];
    
    [self.termsButton underlinedLinkButtonWithText:JZLocalizedString(@"login.termsofuse", @"") fontSize:15.0];
    
    [self.termsButton addTarget:self
                         action:@selector(buttonTapped:)
               forControlEvents:UIControlEventTouchUpInside];
    [_termsButton sizeToFit];
    
    [self.createButton addTarget:self
                          action:@selector(buttonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    self.registerLegalContainerView.alpha = 0.0;
    _registerLegalContainerView.tag = 22222;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) onButtonTapped:(id) sender {
    UIButton *tappedButton = (UIButton *) sender;
    
    switch (tappedButton.tag) {
        case kAuthenticateButtonTag: {
            [self onAuthenticate:tappedButton];
        }
            break;
        case kShowForgotButtonTag: {
            [self setupAndShowScreen:LoginScreenTypeForgotPassword];
        }
            break;
        case kCancelForgotPasswordButtonTag: {
            [self setupAndShowScreen:LoginScreenTypeSocialLogin];
        }
            break;
        default:
            break;
    }
}

-(IBAction) onAuthenticate:(id)sender {
    JoizSDKLoginManager *lm = [JoizSDKLoginManager shared];

//    NSAssert([((UITextField *)[self.view viewWithTag:1]).text length], @"Enter a valid user name in the username field");
//    NSAssert([((UITextField *)[self.view viewWithTag:2]).text length], @"Enter the password in the password field");
    if ([lm isLoggedIn]) {
        __weak AuthViewController *weakSelf = self;
        [JZCloakViewController cloakView:self.view cloakAppeared:^{
            AuthViewController *strongSelf = weakSelf;
            [lm logoutWithCompletionBlock:^{
                [JZCloakViewController uncloak:^{
                    ((UITextField *)[strongSelf.view viewWithTag:1]).enabled = YES;             
                    ((UITextField *)[strongSelf.view viewWithTag:2]).enabled = YES;   
                    UIButton *authButton = (UIButton *) [strongSelf.view viewWithTag:20];
                    
                    [authButton setTitle:@"Authenticate" forState:UIControlStateNormal];
                    
                    [lm cleanAuthenticationData]; 
                    [lm persist];
                }];
            }];
        } blackout:NO];            
    } else {
        NSString *userName = ((UITextField *)[self.view viewWithTag:1]).text;
        if (![userName length]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You must insert a valid username" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            
            return;
        }
        
        NSCharacterSet* notDigits = [[NSCharacterSet characterSetWithCharactersInString:@"+0123456789"] invertedSet];
        if ([userName rangeOfCharacterFromSet:notDigits].location != NSNotFound) {//email
            JoizAuthVerify emailVerify = [lm verifyEmail:userName];
            if (AuthVerifyOK != emailVerify) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You must insert a valid username/phone number (4+10 digits only, max)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                
                return;
            }
        } else {
            JoizPhoneVerify phoneVerify = [lm verifyPhoneNumber:userName];
            if (JoizPhoneVerifyOK != phoneVerify) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You must insert a valid username/phone number (4+10 digits only, max)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                
                return;
            }
        }
        
        NSString *password = ((UITextField *)[self.view viewWithTag:2]).text;
        if (![password length]) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You must insert the password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            
            return;
        }    
        
        lm.queuedUserCredentials = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    userName, @"email",
                                    password, @"plainPassword",
                                    @"email", @"service", 
                                    @"1", @"errors", nil
                                    ];
        lm.loginSettings.serviceType = @(LoginStateLoggedInWithJoiz);
        [JZCloakViewController cloakView:self.view cloakAppeared:^{
            [lm authenticateWithJoiz:@"email"];    
        } blackout:NO];
    }
}

- (void)didVerifyJoizAccountWithStatus:(JoizAccountVerificationResult) authStatus {
    JoizSDKLoginManager *lm = [JoizSDKLoginManager shared];
    __weak AuthViewController *weakSelf = self;
    
    [JZCloakViewController uncloak:^{
        switch (authStatus) {
            case JoizAccountVerificationResultIsNewUser: {
                [UIAlertView bk_showAlertViewWithTitle:@"error"
                                               message:@"User not found"
                                     cancelButtonTitle:nil
                                     otherButtonTitles:[NSArray arrayWithObject:@"yes"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                         //reset UI here
                                     }]; 
            }
                break;
            case JoizAccountVerificationResultFailed: {
                
                [UIAlertView bk_showAlertViewWithTitle:@"error"
                                               message:@"error.login.message"
                                     cancelButtonTitle:nil
                                     otherButtonTitles:[NSArray arrayWithObject:@"yes"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                         //reset UI here
                                     }];                        
            }
                break;
            case JoizAccountVerificationResultOK: {
                ((UITextField *)[weakSelf.view viewWithTag:1]).enabled = NO;             
                ((UITextField *)[weakSelf.view viewWithTag:2]).enabled = NO;   
                UIButton *authButton = (UIButton *) [weakSelf.view viewWithTag:20];
                
                [authButton setTitle:@"Logout" forState:UIControlStateNormal];
                
                [lm.loginSettings setUserAcceptsTerms:YES];

                [lm persist];
                lm.queuedUserCredentials = nil;
            }
                break;
            default:
                break;
        }
        
        [lm print];
    }];
}

- (void)didFailToLoginWithError:(NSString *) errorStr {
    [JZCloakViewController uncloak:^{
    }];

    [[[UIAlertView alloc] initWithTitle:JZLocalizedString(@"error", nil)
                                message:JZLocalizedString(errorStr, nil)
                               delegate:nil
                      cancelButtonTitle:JZLocalizedString(@"error.login.close", nil)
                      otherButtonTitles:nil] show];
}

#pragma mark - Login Delegate
- (void)didSuccessfullyLoginWithServiceInformation:(NSDictionary *)serviceData error:(NSError *)error {
    JoizSDKLoginManager *lm = [JoizSDKLoginManager shared];
    
    NSLog(@"serviceData: %@", serviceData);
    NSDictionary *data = nil;
    __weak AuthViewController *weakSelf = self;
    if (error) {
        [UIAlertView bk_showAlertViewWithTitle:JZLocalizedString(@"error", @"") 
                                       message:JZLocalizedString(@"error.login.message", nil) 
                             cancelButtonTitle:nil
                             otherButtonTitles:[NSArray arrayWithObject:JZLocalizedString(@"answer.yes", @"")] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                 lm.loginSettings.serviceType = @(LoginStateNotLoggedIn);
                                 
//                                 [weakSelf resetUI];
                             }];    
        
        return;
    }
    
    lm.loginSettings.serviceType = [serviceData objectForKey:@"type"];    
    if ([[serviceData objectForKey:@"type"] intValue] == LoginStateLoggedInWithFacebook) {
        //        NSString *trackingCode = [JoizAppSettings qatrackingCodeForKey:kSocialLoginFBSuccess];
        //        [[Analytics sharedAnalytics] trackScreenWithName:trackingCode];
        
        NSMutableDictionary *serviceDataMutable = [NSMutableDictionary dictionaryWithDictionary:serviceData];
        
        //        FBSession *currentSession = [FBSession activeSession];
        NSString *currentToken = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *email = [JoizSDKUtilities safeString:[serviceDataMutable objectForKey:@"email"]];
        
        if ([[JoizSDKLoginManager shared] verifyEmail:email] != AuthVerifyOK) {
            //houston, we have a problem
            [serviceDataMutable removeObjectForKey:@"email"];
        } else {
            serviceDataMutable[@"email"] = email;
        }
        
        if (![serviceDataMutable[@"email"] length] || ![currentToken length]/*![currentSession.accessTokenData.accessToken length]*/) {
            [UIAlertView bk_showAlertViewWithTitle:JZLocalizedString(@"error", @"") 
                                           message:JZLocalizedString(@"error.loginFacebook.message", nil) 
                                 cancelButtonTitle:nil
                                 otherButtonTitles:[NSArray arrayWithObject:JZLocalizedString(@"answer.yes", @"")] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                     lm.loginSettings.serviceType = @(LoginStateNotLoggedIn);
                                     
//                                     [weakSelf resetUI];
                                 }];    
            
            return;        
        }
        
        NSAssert([serviceData objectForKey:@"email"] && [currentToken length] && [lm prettyStringForType:LoginStateLoggedInWithFacebook], @"Incomplete data @facebook service auth");
        data = @{ 
                 @"email" : [serviceData objectForKey:@"email"],
                 @"accessToken" : currentToken, //currentSession.accessTokenData.accessToken,
                 @"service" : [lm prettyStringForType:LoginStateLoggedInWithFacebook], 
                 @"isFacebook": @"1"
                 };
    } else if ([[serviceData objectForKey:@"type"] intValue] == LoginStateLoggedInWithGoogle) { 
        UIButton *cancelButton = (UIButton *) [self.view viewWithTag:3535];
        [cancelButton removeFromSuperview];
        
        NSAssert([serviceData objectForKey:@"email"], @"Incomplete data @google service auth");
        //TODO add email check
        data = @{ 
                 @"email" : [serviceData objectForKey:@"email"],
                 @"accessToken" : [[GPPSignIn sharedInstance].authentication accessToken],
                 @"service" : [lm prettyStringForType:LoginStateLoggedInWithGoogle],
                 @"isGoogle" : @"1"
                 };
    }
    //TODO check
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"login_failed"
                                                  object:nil];
    
    NSAssert(data, @"No data in loginWithService"); 
    lm.queuedUserCredentials = [NSMutableDictionary dictionaryWithDictionary:data]; 
    
    [[JoizSDKLoginManager shared] checkUserData:data onComplete:^(NSString *errorKey, BOOL isNewUser){
        if (errorKey) {
            [UIAlertView bk_showAlertViewWithTitle:JZLocalizedString(@"error", @"") 
                                           message:JZLocalizedString(@"error.login.message", nil) 
                                 cancelButtonTitle:nil
                                 otherButtonTitles:[NSArray arrayWithObject:JZLocalizedString(@"answer.yes", @"")] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                     [weakSelf resetUI];
                                 }];
            
            return;
        }
        
//        if (isNewUser) {
//            [weakSelf navigateForwardToScreen:LoginScreenTypeRegisterLegal addToOffset:1];                                       
//        } else {
//            [lm authenticateWithJoiz:[lm.queuedUserCredentials objectForKey:@"service"]];                             
//        }
    }];
}

-(void) showScreen:(UIView *) navigatingTo {
    if ( !navigatingTo ) {
        return;
    }
    
    navigatingTo.alpha = 0.0;
    
    [self.view addSubview:navigatingTo];
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:navigatingTo
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    NSLayoutConstraint *constraintCenter = [NSLayoutConstraint constraintWithItem:navigatingTo
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
//    NSArray *constraintW = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[navigatingTo(==%f)]", self.parentContainerScrollView.frame.size.width]
//                                                                   options:0
//                                                                   metrics:nil
//                                                                     views:NSDictionaryOfVariableBindings(navigatingTo)];  
//    NSArray *constraintH = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[navigatingTo(==%f)]", self.parentContainerScrollView.frame.size.height]
//                                                                   options:0
//                                                                   metrics:nil
//                                                                     views:NSDictionaryOfVariableBindings(navigatingTo)];
    
    [self.view addConstraints:[NSArray arrayWithObjects:constraintTop, constraintCenter, nil]];
//    [self.view addConstraints:constraintW];
//    [self.view addConstraints:constraintH];
    
    constraintTop = nil;
    constraintCenter = nil;
//    constraintW = nil;
//    constraintH = nil;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
//    self.parentContainerScrollView.contentSize = CGSizeMake((xOffset + 1) * self.parentContainerScrollView.frame.size.width,
//                                                            self.parentContainerScrollView.frame.size.height);
//    [self.parentContainerScrollView setContentOffset:CGPointMake(xOffset * self.parentContainerScrollView.frame.size.width, 0.0) animated:YES];
    
    
//    [self.uiStack addObject:navigatingTo];
    
    __weak AuthViewController *weakSelf = self;
    [UIView animateWithDuration:0.44 animations:^{
        navigatingTo.alpha = 1.0;
        weakSelf.currentScreen.alpha = 0.0;
    } completion:^(BOOL finished) {
        [weakSelf.currentScreen removeFromSuperview];
        weakSelf.currentScreen = navigatingTo;    
    }];
}

#pragma mark UITExtFieldDelegates
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    UITextField *usrName = (UITextField *)[self.view viewWithTag:1];             
    UITextField *pass = (UITextField *)[self.view viewWithTag:2];
    
    if (textField == usrName) {
        [pass becomeFirstResponder];
    } else {
        [pass resignFirstResponder];
    }
    
    return NO;
}

@end

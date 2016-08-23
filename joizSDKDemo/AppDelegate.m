//
//  AppDelegate.m
//  joizSDKDemo
//
//  Created by George Ilies on 13.07.2015.
//  Copyright (c) 2015 Reea. All rights reserved.
//

#import "AppDelegate.h"
#import <joizSDK/JoizSDKAppSettings.h>
#import <joizSDK/JoizSDKLoginManager.h>
#import <joizSDK/JoizAPIClient.h>
#import "Consts.h"
#import "JZSpinner.h"
#import "Notifications.h"
#import "RootViewController.h"
#import "AuthViewController.h"

@interface AppDelegate () {
    NSUInteger _bootStatusFlag;
}

@property (nonatomic, setter=setBootStatusFlag:) NSUInteger bootStatusFlag;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self bootSettings];

    
    if ((_bootStatusFlag & 0xFF) != kBootFlagServerSettingsCompleted) {
        UIViewController* vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        self.window.rootViewController = vc;
        
        vc = nil;
        
        [[JZSpinner defaultSpinner] showWaitView:JZLocalizedString(@"please_wait", nil)
                                    detailedText:@"Loading ..."];
        //        [JZCloakViewController unlockableCloakWithText:JZLocalizedString(@"system.alert.nointernet", @"")];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) bootSettings {   
    JoizSDKAppSettings *appS =[JoizSDKAppSettings singleton];
    [appS loadBundleSettings];
    
//    [LocationManager sharedInstance];
//    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *uuid = @"";    
    if ([[userDefaults objectForKey:kUUID] length]) {
        uuid = [userDefaults objectForKey:kUUID];
    } else {
        uuid = [NSUUID UUID].UUIDString;     
        
        [userDefaults setObject:uuid forKey:kUUID];
        [userDefaults synchronize];
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    JoizAPIClient *apiClient = [JoizAPIClient client];
    [apiClient.requestSerializer setValue:[NSString stringWithFormat:@"%.f", now] forHTTPHeaderField:@"StartID"];
    [apiClient.requestSerializer setValue:uuid forHTTPHeaderField:@"DeviceID"];
    JoizSDKLoginManager *lm = [JoizSDKLoginManager shared];
    NSString *apiToken = [lm joizAPIToken];
    
    if ([lm tokenIsValid:apiToken]) {
        [apiClient setAPIAuthenticationToken:apiToken];     
    }
    
    [[JZSpinner defaultSpinner] showWaitView:JZLocalizedString(@"please_wait", @"") detailedText:JZLocalizedString(@"loading_data", @"")];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(serverSettingsChanged:) 
                                                 name:kNotificationServerSettingsChanged 
                                               object:nil];        
    [appS loadServerSideSettingsForKeys:@[@"API_VISIBILITY",
                                          @"API_GOOGLEPLUS_CLIENT_ID",
                                          @"API_FACEBOOK_ID",
                                          @"API_GOOGLEPLUS_ID",
                                          @"API_GOOGLE_ANALYTICS_IOS",
                                          @"API_NODEJS_URL",
                                          @"API_NODEJS_GROUP",
                                          @"API_OOYALA_APPID",
                                          @"API_OOYALA_APIKEY",
                                          @"API_OOYALA_SECRETKEY",
                                          @"API_OOYALA_PCODE",
                                          @"API_OOYALA_PLAYER_DOMAIN",
                                          @"API_OOYALA_LIVESTREAM_EMBEDCODE",
                                          @"API_LIVESTREAM_PLACEHOLDER_IMAGE"]];
    
    
}

-(void) serverSettingsChanged:(NSNotification *) nObj {   
    NSDictionary *userInfo = [nObj userInfo];
    JoizSettingsLoadStatusEnum serverSettingsStatus = (JoizSettingsLoadStatusEnum) [[userInfo objectForKey:kServerSettingsNewStatus] integerValue];
    
    if (JoizSettingsLoadStatusCompleted == serverSettingsStatus) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationServerSettingsChanged object:nil];        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSAssert([[JoizSDKAppSettings singleton].GooglePlusClientID length], @"%s@%s:%d\n GooglePlusClientID", __FILE__, __PRETTY_FUNCTION__, __LINE__);
        NSAssert([[JoizSDKAppSettings singleton].OoyalaAppId length], @"%s@%s:%d\n OoyalaAppId", __FILE__, __PRETTY_FUNCTION__, __LINE__);
        NSAssert([[JoizSDKAppSettings singleton].OoyalaApiKey length], @"%s@%s:%d\n OoyalaApiKey", __FILE__, __PRETTY_FUNCTION__, __LINE__);                        
        NSAssert([[JoizSDKAppSettings singleton].OoyalaSecretKey length], @"%s@%s:%d\n OoyalaSecretKey", __FILE__, __PRETTY_FUNCTION__, __LINE__);                        
        NSAssert([[JoizSDKAppSettings singleton].OoyalaPCode length], @"%s@%s:%d\n OoyalaPCode", __FILE__, __PRETTY_FUNCTION__, __LINE__);                        
        NSAssert([[JoizSDKAppSettings singleton].OoyalaPlayerDomain length], @"%s@%s:%d\n OoyalaPlayerDomain", __FILE__, __PRETTY_FUNCTION__, __LINE__);                        
        NSAssert([[JoizSDKAppSettings singleton].OoyalaLiveStreamEmbedCode length], @"%s@%s:%d\n OoyalaLiveStreamEmbedCode", __FILE__, __PRETTY_FUNCTION__, __LINE__);       
                
        [userDefaults synchronize];
        [self setBootStatusFlag:kBootFlagServerSettingsCompleted];
    }
}

#pragma mark Acessor methods
-(void) setBootStatusFlag:(NSUInteger) newStat {
    @synchronized(self) {
        _bootStatusFlag |= newStat;
        
        //        if (_bootStatusFlag & kBootFlagRegionDetermined && _bootStatusFlag & kBootFlagDynamicMenu) {
        //              might request here (conditionally) dynamic menu
        //        }
        
        if ((_bootStatusFlag & 0xFF) == kBootFlagServerSettingsCompleted) {
//            JoizSDKLoginManager *lm = [JoizSDKLoginManager shared];

            UINavigationController *navigationController = [[UINavigationController alloc] init];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            RootViewController *rvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"RootViewControllerIdentifier"];
            
            navigationController.navigationBarHidden = NO;
            navigationController.viewControllers = @[rvc];
            
            self.window.rootViewController = navigationController;
            self.window.backgroundColor = [UIColor whiteColor];
            
//            if (![lm isLoggedIn] && [[JoizSDKAppSettings singleton] guestAccessAllowed] <= 0) {   
//                AuthViewController *avc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AuthViewControllerIdentifier"];
//                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:avc];
//            } 
            
            [[JZSpinner defaultSpinner] hideWaitView];
        }
    }
}

@end

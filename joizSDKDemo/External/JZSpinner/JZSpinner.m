//
//  JZSpinner.m
//  
//
//  Created by George Ilies on 13.08.2014.
//
//

#import "JZSpinner.h"
#import "MBProgressHUD.h"

static JZSpinner *instance;

@interface JZSpinner ()

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation JZSpinner

+(id) defaultSpinner {
    if (!instance) {
        instance = [[JZSpinner alloc] init];
    }
    
    return instance;
}

- (void) showWaitView :(NSString*) caption detailedText:(NSString *) detailedText {
    if (self.HUD) {
        [self hideWaitView];
    }

    UIWindow *w = [[[UIApplication sharedApplication] windows] objectAtIndex:0];    
    self.HUD = [[MBProgressHUD alloc] initWithView:w];

    //    appDelegate.HUD.minShowTime = 1.0;
    //appDelegate.HUD.color = [UIColor colorWithRed:1.0f green:0.8392f blue:0.2 alpha:0.8];
    [w addSubview:self.HUD];
    self.HUD.label.text = caption;
    self.HUD.detailsLabel.text = detailedText;
    [self.HUD showAnimated:YES];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) showWaitView :(NSString*) caption detailedText:(NSString *) detailedText hideAfterDuration:(float) showForDuration {
	[self showWaitView:caption detailedText:detailedText];
    
  	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [NSTimer scheduledTimerWithTimeInterval:showForDuration target:instance selector:@selector(hideWaitView) userInfo:nil repeats:NO];
}

- (void) hideWaitView {
    __weak JZSpinner *weakSelf = self;

//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    @synchronized(instance) {
        if (weakSelf.HUD != nil) {
            [weakSelf.HUD hideAnimated:YES];
            [weakSelf.HUD removeFromSuperview];
            weakSelf.HUD = nil;
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }        
//    });
}

@end
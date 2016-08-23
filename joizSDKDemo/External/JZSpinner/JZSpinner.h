//
//  JZSpinner.h
//  
//
//  Created by George Ilies on 13.08.2014.
//
//

#import <Foundation/Foundation.h>

@interface JZSpinner : NSObject

+(id) defaultSpinner;

- (void) showWaitView :(NSString*) caption detailedText:(NSString *) detailedText;
- (void) showWaitView :(NSString*) caption detailedText:(NSString *) detailedText hideAfterDuration:(float) showForDuration;
- (void) hideWaitView;

@end

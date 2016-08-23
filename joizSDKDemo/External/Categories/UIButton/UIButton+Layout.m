//
//  UIButton+Layout.m
//  
//
//  Created by the good spirits of reea
//
//

#import "UIButton+Layout.h"

@implementation UIButton (Layout)

-(void) addBorderWithColor:(UIColor *) borderColor {
    self.clipsToBounds = NO;
    self.layer.cornerRadius = 4.0;
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = 1.0;
}

@end

//
//  RBLShadowedTextFieldCell.h
//  Rebel
//
//  Created by Danny Greg on 18/02/2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSInteger const RBLShadowedTextFieldAllBackgroundStyles;

@interface RBLShadowedTextFieldCell : NSTextFieldCell

- (void)setShadow:(NSShadow *)shadow forBackgroundStyle:(NSBackgroundStyle)backgroundStyle;

@end

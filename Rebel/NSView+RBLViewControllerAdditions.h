//
//  NSView+NSView_RBLViewControllerAdditions.h
//  Rebel
//
//  Created by Colin Wheeler on 10/29/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (NSView_RBLViewControllerAdditions)

- (void)layoutSubviews;
- (void)layoutIfNeeded;
- (void)setNeedsLayout;

@property (nonatomic, assign) IBOutlet NSViewController *viewController;

@end

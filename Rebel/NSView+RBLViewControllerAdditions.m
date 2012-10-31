//
//  NSView+NSView_RBLViewControllerAdditions.m
//  Rebel
//
//  Created by Colin Wheeler on 10/29/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSView+RBLViewControllerAdditions.h"
#import "RBLViewController.h"
#import "NSObject+RBObjectSizzlingAdditions.h"
#import <objc/runtime.h>

void *kRBLViewControllerKey = &kRBLViewControllerKey;
void *KRBLViewNeedsLayoutKey = &KRBLViewNeedsLayoutKey;

@implementation NSView (NSView_RBLViewControllerAdditions)

+ (void)initialize {
    if(self == [NSView class]) {
        [self loadSupportForLayoutSubviews];
    }
}

#pragma mark - ViewController

-(id)viewController {
	return objc_getAssociatedObject(self, kRBLViewControllerKey);
}

-(void)setViewController:(id)newViewController {
	if (self.viewController) {
		NSResponder *controllerNextResponder = [self.viewController nextResponder];
		[self setNextResponder:controllerNextResponder];
		[self.viewController setNextResponder:nil];
	}
	
	objc_setAssociatedObject(self, kRBLViewControllerKey, newViewController, OBJC_ASSOCIATION_ASSIGN);
	
	if (newViewController) {
		NSResponder *ownResponder = [self nextResponder];
		[self setNextResponder:self.viewController];
		[self.viewController setNextResponder:ownResponder];
	}
}

#pragma mark - Layout Subviews

+ (void)loadSupportForLayoutSubviews {
    [self swapMethod:@selector(setBounds:) with:@selector(custom_setBounds:)];
    [self swapMethod:@selector(setFrame:) with:@selector(custom_setFrame:)];
    [self swapMethod:@selector(viewWillDraw) with:@selector(custom_viewWillDraw)];
}

- (void)custom_setBounds:(NSRect)newBounds {
    [self custom_setBounds:newBounds];
    
    [self setNeedsLayout];
}

- (void)custom_setFrame:(NSRect)newFrame {
    [self custom_setFrame:newFrame];
    
    [self setNeedsLayout];
}

- (void)custom_viewWillDraw {
    [self layoutIfNeeded];
    
    [self custom_viewWillDraw];
}

- (void)layoutIfNeeded {
    if([self needsLayout]) {
        [self layoutSubviews];
    }
}

- (void)layoutSubviews {
    objc_setAssociatedObject(self, KRBLViewNeedsLayoutKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setNeedsLayout {
    objc_setAssociatedObject(self, KRBLViewNeedsLayoutKey, [NSNull null], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setNeedsDisplay:YES];
}

- (BOOL)needsLayout {
    return objc_getAssociatedObject(self, KRBLViewNeedsLayoutKey) != nil;
}

#pragma mark - View Methods

+(void)loadSupportForRBLViewControllers {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//swizzle swizzle...
		[self swapMethod:@selector(viewWillMoveToSuperview:) with:@selector(custom_viewWillMoveToSuperview:)];
        [self swapMethod:@selector(viewDidMoveToSuperview) with:@selector(custom_viewDidMoveToSuperview)];
        
        [self swapMethod:@selector(viewWillMoveToWindow:) with:@selector(custom_viewWillMoveToWindow:)];
        [self swapMethod:@selector(viewDidMoveToWindow) with:@selector(custom_viewDidMoveToWindow)];
        
        [self swapMethod:@selector(setNextResponder:) with:@selector(custom_setNextResponder:)];
	});
}

- (void)custom_viewWillMoveToSuperview:(NSView *)newSuperview {
	[self custom_viewWillMoveToSuperview:newSuperview];
	
	if ([self.viewController isKindOfClass:[RBLViewController class]]) {
		if (newSuperview == nil) {
			[(RBLViewController *)self.viewController viewWillBeRemovedFromSuperview];
			
			if ((self.superview != nil) && (self.window != nil)) {
				[(RBLViewController	*)self.viewController viewWillDisappear];
			}
		} else {
			[(RBLViewController *)self.viewController viewWillMoveToSuperview:newSuperview];
			
			if (self.window != nil) {
				[(RBLViewController *)self.viewController viewWillAppear];
			}
		}
	}
}

- (void)custom_viewDidMoveToSuperview {
	[self custom_viewDidMoveToSuperview];
	
	if ([self.viewController isKindOfClass:[RBLViewController class]]) {
		if (self.superview == nil) {
			[(RBLViewController *)self.viewController viewWasRemovedFromSuperview];
			
			if (self.window == nil) {
				[(RBLViewController *)self.viewController viewDidDisappear];
			}
		} else {
			[(RBLViewController *)self.viewController viewDidMoveToSuperview];
			
			if (self.window != nil) {
				[(RBLViewController *)self.viewController viewDidAppear];
			}
		}
	}
}

- (void)custom_viewWillMoveToWindow:(NSWindow *)newWindow {
	[self custom_viewWillMoveToWindow:newWindow];
	
	if ([self.viewController isKindOfClass:[RBLViewController class]]) {
		if (newWindow == nil) {
			[(RBLViewController *)self.viewController viewWillBeRemovedFromWindow];
			
			if ((self.superview != nil) && (self.window != nil)) {
				[(RBLViewController *)self.viewController viewWillDisappear];
			}
		} else {
			[(RBLViewController *)self.viewController viewWillMoveToWindow:newWindow];
			
			if (self.superview != nil) {
				[(RBLViewController *)self.viewController viewWillAppear];
			}
		}
	}
}

- (void)custom_viewDidMoveToWindow {
	[self custom_viewDidMoveToWindow];
	
	if ([self.viewController isKindOfClass:[RBLViewController class]]) {
		if (self.window == nil) {
			[(RBLViewController *)self.viewController viewWasRemovedFromWindow];
			
			if (self.superview == nil) {
				[(RBLViewController *)self.viewController viewDidDisappear];
			}
		} else {
			[(RBLViewController *)self.viewController viewDidMoveToWindow];
			
			if (self.superview != nil) {
				[(RBLViewController *)self.viewController viewDidAppear];
			}
		}
	}
}

- (void)custom_setNextResponder:(NSResponder *)newNextResponder {
	if (self.viewController != nil) {
		[self.viewController setNextResponder:newNextResponder];
		return;
	}
	
	[self custom_setNextResponder:newNextResponder];
}

@end

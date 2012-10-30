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

@implementation NSView (NSView_RBLViewControllerAdditions)

#pragma mark - ViewController

-(id)viewController
{
	return objc_getAssociatedObject(self, kRBLViewControllerKey);
}

-(void)setViewController:(id)newViewController
{
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

#pragma mark - Custom Methods

+(void)loadSupportForRBLViewControllers
{
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

- (void)custom_viewWillMoveToSuperview:(NSView *)newSuperview
{
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

- (void)custom_viewDidMoveToSuperview
{
	[self custom_viewDidMoveToSuperview];
	
	
}

- (void)custom_viewWillMoveToWindow:(NSWindow *)newWindow
{
	[self custom_viewWillMoveToWindow:newWindow];
	
	
}

- (void)custom_viewDidMoveToWindow
{
	[self custom_viewDidMoveToWindow];
	
	
}

- (void)custom_setNextResponder:(NSResponder *)newNextResponder
{
	[self custom_setNextResponder:newNextResponder];
	
	
}

@end

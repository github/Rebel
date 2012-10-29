//
//  NSView+NSView_RBLViewControllerAdditions.m
//  Rebel
//
//  Created by Colin Wheeler on 10/29/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSView+RBLViewControllerAdditions.h"
#import <objc/runtime.h>

void *kRBLViewControllerKey = &kRBLViewControllerKey;

static BOOL hasSwizzledMethods = NO;

@implementation NSView (NSView_RBLViewControllerAdditions)

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

@end

//
//  RBLOutlineView.m
//  Rebel
//
//  Created by Rob Rix on 26/05/2014.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "RBLOutlineView.h"

@implementation RBLOutlineView

- (BOOL)scrollRectToVisible:(NSRect)aRect {
	NSScrollView *scrollView = self.enclosingScrollView;
	NSRect visibleRect = self.visibleRect;
	
	void (^scrollToY)(CGFloat) = ^(CGFloat y) {
		NSPoint pointToScrollTo = NSMakePoint(0, y);
		
		[scrollView.contentView scrollToPoint:pointToScrollTo];
		[scrollView reflectScrolledClipView:scrollView.contentView];
	};
	
	if (NSMinY(aRect) < NSMinY(visibleRect)) {
		scrollToY(NSMinY(aRect));
		return YES;
	}
	
	if (NSMaxY(aRect) > NSMaxY(visibleRect)) {
		scrollToY(NSMaxY(aRect) - NSHeight(visibleRect));
		return YES;
	}
	
	return NO;
}

@end

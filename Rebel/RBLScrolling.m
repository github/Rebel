//
//  RBLScrolling.m
//  Rebel
//
//  Created by Rob Rix on 27/05/2014.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "RBLScrolling.h"

BOOL RBLScrollRectInViewToVisible(NSView *view, NSRect rect) {
	NSScrollView *scrollView = view.enclosingScrollView;
	NSRect visibleRect = view.visibleRect;
	
	void (^scrollToY)(CGFloat) = ^(CGFloat y) {
		NSPoint pointToScrollTo = NSMakePoint(0, y);
		
		[scrollView.contentView scrollToPoint:pointToScrollTo];
		[scrollView reflectScrolledClipView:scrollView.contentView];
	};
	
	if (NSMinY(rect) < NSMinY(visibleRect)) {
		scrollToY(NSMinY(rect));
		return YES;
	}
	
	if (NSMaxY(rect) > NSMaxY(visibleRect)) {
		scrollToY(NSMaxY(rect) - NSHeight(visibleRect));
		return YES;
	}
	
	return NO;
}

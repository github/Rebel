//
//  RBLScrolling.m
//  Rebel
//
//  Created by Rob Rix on 27/05/2014.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "RBLScrolling.h"

@interface NSScrollView (RBLScrolling1010APIs)

@property NSEdgeInsets contentInsets;

@end

BOOL RBLScrollRectInViewToVisible(NSView *view, NSRect rect) {
	NSScrollView *scrollView = view.enclosingScrollView;
	NSRect visibleRect = view.visibleRect;

	NSEdgeInsets insets = NSEdgeInsetsMake(0, 0, 0, 0);
	if ([scrollView respondsToSelector:@selector(contentInsets)]) {
		insets = scrollView.contentInsets;
	}
	
	void (^scrollToY)(CGFloat) = ^(CGFloat y) {
		NSPoint pointToScrollTo = NSMakePoint(0, y);
		
		[scrollView.contentView scrollToPoint:pointToScrollTo];
		[scrollView reflectScrolledClipView:scrollView.contentView];
	};
	
	if (NSMinY(rect) < NSMinY(visibleRect)) {
		scrollToY(NSMinY(rect) - insets.top);
		return YES;
	}
	
	if (NSMaxY(rect) > NSMaxY(visibleRect)) {
		scrollToY(NSMaxY(rect) - NSHeight(visibleRect) + insets.bottom);
		return YES;
	}
	
	return NO;
}

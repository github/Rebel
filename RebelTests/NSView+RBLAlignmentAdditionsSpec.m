//
//  NSView+RBLAlignmentAdditionsSpec.m
//  Rebel
//
//  Created by Indragie Karunaratne on 2013-03-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

SpecBegin(NSViewRBLAlignmentAdditions)

describe(@"view alignment", ^{
	NSRect nonAlignedRect = NSMakeRect(10.2, 11.8, 12, 13);
	NSRect expectedRect = NSMakeRect(10, 12, 12, 13);

	__block NSView *view;

	before(^{
		 view = [[NSView alloc] initWithFrame:NSMakeRect(20, 20, 20, 20)];
	});

	it(@"should return a rect aligned to the view backing", ^{
		NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100) styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
		[window.contentView addSubview:view];

		NSRect alignedRect = [view rbl_viewBackingAlignedRect:nonAlignedRect options:NSAlignAllEdgesNearest];
		expect(NSEqualRects(alignedRect, expectedRect)).to.beTruthy();
	});

	it(@"should return a rect aligned to the view backing without a window", ^{
		NSRect alignedRect = [view rbl_viewBackingAlignedRect:nonAlignedRect options:NSAlignAllEdgesNearest];
		expect(NSEqualRects(alignedRect, expectedRect)).to.beTruthy();
	});
});

SpecEnd

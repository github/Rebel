//
//  NSView+RBLAlignmentAdditionsSpec.m
//  Rebel
//
//  Created by Indragie Karunaratne on 2013-03-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

SpecBegin(NSViewRBLAlignmentAdditions)

describe(@"view alignment", ^{
	__block NSView *view;
	before(^{
		 view = [[NSView alloc] initWithFrame:NSMakeRect(20.f, 20.f, 20.f, 20.f)];
	});
	it(@"should return a rect aligned to the view backing", ^{
		NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.f, 0.f, 100.f, 100.f) styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
		[window.contentView addSubview:view];
	});
	it(@"should return a rect aligned to the view backing without a window.", ^{});
	after(^{
		NSRect nonAlignedRect = NSMakeRect(10.2f, 11.8f, 12.f, 13.f);
		NSRect alignedRect = [view rbl_viewBackingAlignedRect:nonAlignedRect options:NSAlignAllEdgesNearest];
		expect(NSEqualRects(alignedRect, NSMakeRect(10.f, 12.f, 12.f, 13.f))).to.beTruthy();
	});
});

SpecEnd
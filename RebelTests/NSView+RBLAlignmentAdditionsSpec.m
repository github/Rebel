//
//  NSView+RBLAlignmentAdditionsSpec.m
//  Rebel
//
//  Created by Indragie Karunaratne on 2013-03-22.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

SpecBegin(NSViewRBLAlignmentAdditions)

describe(@"view alignment", ^{
	it(@"should return a rect aligned to the view backing", ^{
		NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.f, 0.f, 100.f, 100.f) styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
		NSRect nonAlignedRect = NSMakeRect(10.2f, 11.8f, 12.f, 13.f);
		NSRect alignedRect = [window.contentView rbl_viewBackingAlignedRect:nonAlignedRect options:NSAlignAllEdgesNearest];
		expect(NSEqualRects(alignedRect, NSMakeRect(10.f, 12.f, 12.f, 13.f))).to.beTruthy();
	});
});

SpecEnd
//
//  RBLViewSpec.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <Quick/Quick.h>
#import <Rebel/Rebel.h>

QuickSpecBegin(RBLViewSpec)

__block RBLView *view;
__block void (^moveAroundAndVerify)(dispatch_block_t);

before(^{
	view = [[RBLView alloc] initWithFrame:NSZeroRect];
	expect(view).notTo.beNil();

	moveAroundAndVerify = [^(dispatch_block_t block) {
		NSLog(@"Verifying normally…");
		block();

		NSLog(@"Verifying after moving to a new view…");
		NSView *otherView = [[NSView alloc] initWithFrame:NSZeroRect];
		[otherView addSubview:view];
		block();

		NSLog(@"Verifying after being removed from superview…");
		[view removeFromSuperview];
		block();

		NSLog(@"Verifying after adding a subview…");
		[view addSubview:otherView];
		block();

		NSLog(@"Verifying after moving to a new window…");
		NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 500, 500) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
		[window.contentView addSubview:view];
		block();
	} copy];
});

it(@"should be layer-backed", ^{
	expect(view.layer).notTo.beNil();
	expect(view.wantsLayer).to.beTruthy();
});

it(@"should match documented defaults", ^{
	expect(view.backgroundColor).to.beNil();
	expect(view.opaque).to.beFalsy();
	expect(view.clipsToBounds).to.beFalsy();
	expect(view.cornerRadius).to.equal(0);
	expect(view.clearsContextBeforeDrawing).to.beTruthy();
	expect(view.layerContentsRedrawPolicy).to.equal(NSViewLayerContentsRedrawNever);
});

it(@"should set backgroundColor on its backing layer", ^{
	view.backgroundColor = NSColor.redColor;

	moveAroundAndVerify(^{
		expect(view.backgroundColor).to.equal(NSColor.redColor);

		CGColorRef layerColor = view.layer.backgroundColor;
		expect(layerColor).notTo.beNil();
		expect(CGColorEqualToColor(layerColor, NSColor.redColor.rbl_CGColor)).to.beTruthy();
	});
});

it(@"should set masksToBounds on its backing layer", ^{
	view.clipsToBounds = YES;

	moveAroundAndVerify(^{
		expect(view.clipsToBounds).to.beTruthy();
		expect(view.layer.masksToBounds).to.beTruthy();
	});
});

it(@"should set cornerRadius on its backing layer", ^{
	view.cornerRadius = 3;

	moveAroundAndVerify(^{
		expect(view.cornerRadius).to.beCloseTo(3);
		expect(view.layer.cornerRadius).to.beCloseTo(3);
	});
});

QuickSpecEnd

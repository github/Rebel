//
//  RBLViewSpec.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

SpecBegin(RBLView)

__block RBLView *view;

before(^{
	view = [[RBLView alloc] initWithFrame:NSZeroRect];
	expect(view).notTo.beNil();
});

it(@"should be layer-backed", ^{
	expect(view.layer).notTo.beNil();
	expect(view.wantsLayer).to.beTruthy();
});

it(@"should match documented defaults", ^{
	expect(view.backgroundColor).to.beNil();
	expect(view.opaque).to.beFalsy();
	expect(view.clearsContextBeforeDrawing).to.beTruthy();
	expect(view.layerContentsRedrawPolicy).to.equal(NSViewLayerContentsRedrawNever);
});

it(@"should get the backgroundColor of its backing layer", ^{
	view.layer.backgroundColor = CGColorGetConstantColor(kCGColorWhite);

	NSColor *color = view.backgroundColor;
	expect(color).notTo.beNil();
	expect(color.whiteComponent).to.beCloseTo(1.0);
	expect(color.alphaComponent).to.beCloseTo(1.0);
});

it(@"should set the backgroundColor of its backing layer", ^{
	view.backgroundColor = NSColor.redColor;

	CGColorRef layerColor = view.layer.backgroundColor;
	expect(layerColor).notTo.beNil();
	expect(CGColorEqualToColor(layerColor, NSColor.redColor.rbl_CGColor)).to.beTruthy();
});

SpecEnd

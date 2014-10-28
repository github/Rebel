//
//  NSView+RBLAnimationAdditionsSpec.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-09-04.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <Quick/Quick.h>
#import <Rebel/Rebel.h>

QuickSpecBegin(NSViewRBLAnimationAdditions)

describe(@"animation contexts", ^{
	it(@"should not be in an animation context by default", ^{
		expect(NSView.rbl_isInAnimationContext).to.beFalsy();
	});

	it(@"should not be in an animation context within a new NSAnimationContext", ^{
		[NSAnimationContext beginGrouping];
		expect(NSView.rbl_isInAnimationContext).to.beFalsy();
		[NSAnimationContext endGrouping];

		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
			expect(NSView.rbl_isInAnimationContext).to.beFalsy();
		} completionHandler:^{}];
	});

	it(@"should be in an animation context within a Rebel block-based animation", ^{
		[NSView rbl_animate:^{
			expect(NSView.rbl_isInAnimationContext).to.beTruthy();

			[NSView rbl_animate:^{
				expect(NSView.rbl_isInAnimationContext).to.beTruthy();
			} completion:nil];

			expect(NSView.rbl_isInAnimationContext).to.beTruthy();
		} completion:nil];

		expect(NSView.rbl_isInAnimationContext).to.beFalsy();
	});
});

describe(@"animator proxies", ^{
	NSView *view = [[NSView alloc] initWithFrame:NSZeroRect];

	it(@"should not return an animator proxy outside of an animation context", ^{
		// to.beEqual() will invoke -isEqual:, which might pass even if they're
		// not identical.
		expect(view.rbl_animator == view).to.beTruthy();
	});

	it(@"should return an animator proxy within an animation context", ^{
		[NSView rbl_animate:^{
			expect(view.rbl_animator == view).to.beFalsy();
		} completion:nil];
	});
});

QuickSpecEnd

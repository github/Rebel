//
//  RBLTableView.m
//  Rebel
//
//  Created by Jonathan Willing on 12/4/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//
#import "RBLClipView.h"
#import "RBLScrollView.h"
SpecBegin(RBLScrollView)

__block RBLScrollView *scrollView;
__block NSWindow *window;

describe(@"clip view", ^{
	before(^{
		CGRect b = CGRectMake(0, 0, 200, 200);
		window = [[NSWindow alloc] initWithContentRect:b styleMask:0 backing:NSBackingStoreBuffered defer:NO];
		scrollView = [[RBLScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
		[window.contentView addSubview:scrollView];
	});
	
	it(@"should not be null", ^{
		expect(scrollView.contentView).toNot.beNil();
	});

	it(@"should be a RBLClipView", ^{
		expect(scrollView.contentView).to.beKindOf(RBLClipView.class);
	});
});

SpecEnd

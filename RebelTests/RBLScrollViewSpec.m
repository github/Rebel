//
//  RBLTableView.m
//  Rebel
//
//  Created by Jonathan Willing on 12/4/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <Quick/Quick.h>
#import <Rebel/Rebel.h>

QuickSpecBegin(RBLScrollViewSpec)

__block RBLScrollView *scrollView;

describe(@"clip view", ^{
	before(^{
		scrollView = [[RBLScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	});

	it(@"should be a RBLClipView", ^{
		expect(scrollView.contentView).to.beKindOf(RBLClipView.class);
	});
});

QuickSpecEnd

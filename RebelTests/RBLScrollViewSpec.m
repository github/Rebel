//
//  RBLTableView.m
//  Rebel
//
//  Created by Jonathan Willing on 12/4/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

SpecBegin(RBLScrollView)

__block RBLScrollView *scrollView;

describe(@"clip view", ^{
	before(^{
		scrollView = [[RBLScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	});
	
	it(@"should be a RBLClipView", ^{
		expect(scrollView.contentView).to.beKindOf(RBLClipView.class);
	});
});

SpecEnd

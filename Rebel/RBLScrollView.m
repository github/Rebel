//
//  RBLTableView.m
//  Rebel
//
//  Created by Jonathan Willing on 12/4/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLScrollView.h"
#import "RBLClipView.h"

@implementation RBLScrollView

#pragma mark Clip view swapping

- (void)viewDidMoveToSuperview {
	[super viewDidMoveToSuperview];
	
	if (self.contentView != nil && ![self.contentView isKindOfClass:RBLClipView.class] ) {
		[self swapClipView];
	}
}

- (void)swapClipView {
	id documentView = self.contentView;
	RBLClipView *clipView = [[RBLClipView alloc] initWithFrame:self.contentView.frame];
	self.contentView = clipView;
	self.documentView = documentView;
}

@end

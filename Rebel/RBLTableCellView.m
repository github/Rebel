//
//  RBLTableCellView.m
//  Rebel
//
//  Created by Jonathan Willing on 10/23/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLTableCellView.h"

@implementation RBLTableCellView

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
	[super viewWillMoveToSuperview:newSuperview];

	if (self.superview == nil && newSuperview != nil) {
		[self prepareForReuse];
	}
}

- (void)prepareForReuse {
	
}

@end

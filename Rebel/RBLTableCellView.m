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
	if (newSuperview) {
		[self cellViewWillReuse];
	}
}

- (void)viewDidMoveToSuperview {
	if (self.superview) {
		[self cellViewDidReuse];
	}
}

- (void)cellViewWillReuse {
	
}

- (void)cellViewDidReuse {
	
}

@end

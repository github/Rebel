//
//  RBLTableView.m
//  Rebel
//
//  Created by Danny Greg on 20/04/2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RBLTableView.h"
#import "RBLScrolling.h"

@implementation RBLTableView

- (BOOL)scrollRectToVisible:(NSRect)aRect {
	return RBLScrollRectInViewToVisible(self, aRect);
}

@end

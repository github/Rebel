//
//  RBLOutlineView.m
//  Rebel
//
//  Created by Rob Rix on 26/05/2014.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "RBLOutlineView.h"
#import "RBLScrolling.h"

@implementation RBLOutlineView

- (BOOL)scrollRectToVisible:(NSRect)aRect {
	return RBLScrollRectInViewToVisible(self, aRect);
}

@end

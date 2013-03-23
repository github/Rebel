//
//  NSView+RBLAlignmentAdditions.m
//  Rebel
//
//  Created by Indragie Karunaratne on 2013-03-02.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSView+RBLAlignmentAdditions.h"

@implementation NSView (RBLAlignmentAdditions)

- (NSRect)rbl_viewBackingAlignedRect:(NSRect)rect options:(NSAlignmentOptions)options {
	NSRect windowRect = [self convertRect:rect toView:nil];
	NSRect windowBackingRect = [self backingAlignedRect:windowRect options:options];
	return [self convertRect:windowBackingRect fromView:nil];
}

@end

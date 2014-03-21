//
//  RPDAppDelegate.m
//  RBLPopoverDemo
//
//  Created by Matt Diephouse on 2/24/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "RPDAppDelegate.h"

#import "RPDContentViewController.h"

@interface RPDAppDelegate ()

@property (strong, nonatomic) IBOutlet NSSegmentedControl *preferredEdgeControl;
@property (strong, nonatomic) IBOutlet NSSegmentedControl *behaviorControl;

@property (strong, nonatomic, readonly) NSPopover *NSPopover;
@property (strong, nonatomic, readonly) RBLPopover *RBLPopover;

@property (strong, nonatomic) NSNumber *arrowWidth;
@property (strong, nonatomic) NSNumber *arrowHeight;

@property (strong, nonatomic) NSNumber *anchorPointX;
@property (strong, nonatomic) NSNumber *anchorPointY;

@end

@implementation RPDAppDelegate

#pragma mark - NSApplicationDelegate

- (instancetype)init {
	self = [super init];
	if (self == nil) return nil;
	
	_NSPopover = [NSPopover new];
	self.NSPopover.contentViewController = [RPDContentViewController new];
	
	_RBLPopover = [[RBLPopover alloc] initWithContentViewController:[RPDContentViewController new]];
	self.RBLPopover.canBecomeKey = YES;
	
	return self;
}

#pragma mark - Actions

- (IBAction)showNSPopover:(id)sender {
	if (self.NSPopover.shown) {
		[self.NSPopover close];
	} else {
		NSView *button = sender;
		self.NSPopover.behavior = self.behavior;
		
		NSRectEdge edge = self.preferredEdge;
		if (button.isFlipped) {
			if (edge == NSMaxYEdge) {
				edge = NSMinYEdge;
			} else if (edge == NSMinYEdge) {
				edge = NSMaxYEdge;
			}
		}
		[self.NSPopover showRelativeToRect:button.bounds ofView:button preferredEdge:edge];
	}
}

- (IBAction)showRBLPopover:(id)sender {
	if (self.RBLPopover.shown) {
		[self.RBLPopover close];
	} else {
		NSView *button = sender;
		self.RBLPopover.behavior = self.behavior;
		[self.RBLPopover showRelativeToRect:CGRectZero ofView:button preferredEdge:(CGRectEdge)self.preferredEdge];
	}
}

#pragma mark - Configurable Properties

- (NSPopoverBehavior)behavior {
	NSInteger segment = self.behaviorControl.selectedSegment;
	return [self.behaviorControl.cell tagForSegment:segment];
}

- (NSRectEdge)preferredEdge {
	NSInteger segment = self.preferredEdgeControl.selectedSegment;
	return (CGRectEdge)[self.preferredEdgeControl.cell tagForSegment:segment];
}

- (NSNumber *)arrowHeight {
	return @(self.RBLPopover.backgroundView.arrowSize.height);
}

- (void)setArrowHeight:(NSNumber *)arrowHeight {
	CGSize size = self.RBLPopover.backgroundView.arrowSize;
	size.height = arrowHeight.integerValue;
	self.RBLPopover.backgroundView.arrowSize = size;
}

- (NSNumber *)arrowWidth {
	return @(self.RBLPopover.backgroundView.arrowSize.width);
}

- (void)setArrowWidth:(NSNumber *)arrowWidth {
	CGSize size = self.RBLPopover.backgroundView.arrowSize;
	size.width = arrowWidth.integerValue;
	self.RBLPopover.backgroundView.arrowSize = size;
}

- (NSNumber *)anchorPointX {
	return @(self.RBLPopover.anchorPoint.x);
}

- (void)setAnchorPointX:(NSNumber *)anchorPointX {
	CGPoint point = self.RBLPopover.anchorPoint;
	point.x = anchorPointX.floatValue;
	self.RBLPopover.anchorPoint = point;
}

- (NSNumber *)anchorPointY {
	return @(self.RBLPopover.anchorPoint.y);
}

- (void)setAnchorPointY:(NSNumber *)anchorPointY {
	CGPoint point = self.RBLPopover.anchorPoint;
	point.x = anchorPointY.floatValue;
	self.RBLPopover.anchorPoint = point;
}

@end

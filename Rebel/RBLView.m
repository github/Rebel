//
//  RBLView.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLView.h"
#import "NSColor+RBLAdditions.h"

@interface RBLView () {
	struct {
		unsigned opaque:1;
	} _flags;
}

@end

@implementation RBLView

#pragma mark Properties

- (NSColor *)backgroundColor {
	return [NSColor rbl_colorWithCGColor:self.layer.backgroundColor];
}

- (void)setBackgroundColor:(NSColor *)color {
	self.layer.backgroundColor = color.rbl_CGColor;
}

- (BOOL)isOpaque {
	return _flags.opaque;
}

- (void)setOpaque:(BOOL)value {
	_flags.opaque = (value ? 1 : 0);
}

#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;

	self.wantsLayer = YES;
	self.layerContentsPlacement = NSViewLayerContentsPlacementScaleAxesIndependently;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawDuringViewResize;

	return self;
}

@end

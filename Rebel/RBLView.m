//
//  RBLView.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLView.h"
#import "NSColor+RBLAdditions.h"

/*
 * The implementation pointer for -[RBLView drawRect:], used to identify when
 * the method is overridden by subclasses.
 */
static IMP RBLViewDrawRectIMP;

@interface RBLView () {
	struct {
		unsigned opaque:1;
		unsigned clearsContextBeforeDrawing:1;
	} _flags;
}

/*
 * Whether this subclass of RBLView overrides -drawRect:.
 */
+ (BOOL)doesCustomDrawing;

@end

@implementation RBLView

#pragma mark Initialization

+ (void)initialize {
	if (self != [RBLView class]) return;

	RBLViewDrawRectIMP = [self instanceMethodForSelector:@selector(drawRect:)];
}

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

- (BOOL)clearsContextBeforeDrawing {
	return _flags.clearsContextBeforeDrawing;
}

- (void)setClearsContextBeforeDrawing:(BOOL)value {
	_flags.clearsContextBeforeDrawing = (value ? 1 : 0);
}

#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;

	self.wantsLayer = YES;
	self.layerContentsPlacement = NSViewLayerContentsPlacementScaleAxesIndependently;

	if ([self.class doesCustomDrawing]) {
		// Use more conservative defaults if -drawRect: is overridden, to ensure
		// correct drawing. Callers or subclasses can override these defaults
		// to optimize for performance instead.
		self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawDuringViewResize;
	} else {
		self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
	}

	return self;
}

#pragma mark Drawing

+ (BOOL)doesCustomDrawing {
	return [self instanceMethodForSelector:@selector(drawRect:)] != RBLViewDrawRectIMP;
}

- (void)drawRect:(NSRect)rect {
	CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;

	if (self.clearsContextBeforeDrawing) {
		CGContextClearRect(context, rect);
	}
}

@end

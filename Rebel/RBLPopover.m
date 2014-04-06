//
//  RBLPopover.m
//  Rebel
//
//  Created by Danny Greg on 13/09/2012.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLPopover.h"

#import "NSColor+RBLCGColorAdditions.h"
#import "NSView+RBLAnimationAdditions.h"

//***************************************************************************

// Returns the median X value of the shared segment of the X edges of the given rects
static CGFloat RBLRectsGetMedianX(CGRect r1, CGRect r2) {
	CGFloat minX = fmax(NSMinX(r1), NSMinX(r2));
	CGFloat maxX = fmin(NSMaxX(r1), NSMaxX(r2));
	return (minX + maxX) / 2;
}

// Returns the median X value of the shared segment of the X edges of the given rects
static CGFloat RBLRectsGetMedianY(CGRect r1, CGRect r2) {
	CGFloat minY = fmax(NSMinY(r1), NSMinY(r2));
	CGFloat maxY = fmin(NSMaxY(r1), NSMaxY(r2));
	return (minY + maxY) / 2;
}

//***************************************************************************

// A class which forcably draws `NSClearColor.clearColor` around a given path,
// effectively clipping any views to the path. You can think of it like a
// `maskLayer` on a `CALayer`.
@interface RBLPopoverClippingView : NSView

// The path which the view will clip to. The clippingPath will be retained and
// released automatically.
@property (nonatomic) CGPathRef clippingPath;

@end

//***************************************************************************

// We'll use this as RBLPopover's backing window. Since it's borderless, we
// just override the `isKeyWindow` method to make it behave in the way that
// `canBecomeKey` demands.
@interface RBLPopoverWindow : NSWindow

@property (nonatomic) BOOL canBeKey;

@end

//***************************************************************************

@interface RBLPopoverBackgroundView ()

// The clipping view that's used to shape the popover to the correct path. This
// property is prefixed because it's private and this class is meant to be
// subclassed.
@property (nonatomic, strong, readonly) RBLPopoverClippingView *rbl_clippingView;

@property (nonatomic, assign, readwrite) CGRectEdge popoverEdge;

@property (nonatomic, assign, readwrite) NSRect popoverOrigin;

@property (nonatomic, assign, readwrite) NSPoint popoverAnchorPoint;

@property (nonatomic, assign, readwrite) BOOL didOffsetFrame;

- (CGRectEdge)rbl_arrowEdgeForPopoverEdge:(CGRectEdge)popoverEdge;

@end

//***************************************************************************

@interface RBLPopover ()

// The window we are using to display the popover.
@property (nonatomic, strong) RBLPopoverWindow *popoverWindow;

// The identifier for the event monitor we are using to watch for mouse clicks
// outisde of the popover.
// We are not responsible for its memory management.
@property (nonatomic, copy) NSSet *transientEventMonitors;

// The size the content view was before the popover was shown.
@property (nonatomic) CGSize originalViewSize;

// Correctly removes our event monitor watching for mouse clicks external to the
// popover.
- (void)removeEventMonitors;

@end

//***************************************************************************

@implementation RBLPopoverClippingView

- (void)dealloc {
	self.clippingPath = NULL;
}

- (NSView *)hitTest:(NSPoint)aPoint {
	return nil;
}

- (void)setClippingPath:(CGPathRef)clippingPath {
	if (clippingPath == _clippingPath) return;
	
	CGPathRelease(_clippingPath);
	_clippingPath = clippingPath;
	CGPathRetain(_clippingPath);
	
	self.needsDisplay = YES;
}

- (void)drawRect:(NSRect)dirtyRect {
	if (self.clippingPath == NULL) return;
	
	CGContextRef currentContext = NSGraphicsContext.currentContext.graphicsPort;
	CGContextAddRect(currentContext, self.bounds);
	CGContextAddPath(currentContext, self.clippingPath);
	CGContextSetBlendMode(currentContext, kCGBlendModeCopy);
	[NSColor.clearColor set];
	CGContextEOFillPath(currentContext);
}

@end

//***************************************************************************

@implementation RBLPopoverWindow

- (BOOL)canBecomeKeyWindow {
	return self.canBeKey;
}

@end

//***************************************************************************

@implementation RBLPopover

- (instancetype)initWithContentViewController:(NSViewController *)viewController {
	RBLPopoverBackgroundView *view = [[RBLPopoverBackgroundView alloc] initWithFrame:NSZeroRect];
	return [self initWithContentViewController:viewController backgroundView:view];
}

- (instancetype)initWithContentViewController:(NSViewController *)viewController backgroundView:(RBLPopoverBackgroundView *)backgroundView {
	self = [super init];
	if (self == nil)
		return nil;
	

	self.anchorPoint = CGPointMake(0.5, 0.5);
	_contentViewController = viewController;
	_backgroundView = backgroundView;
	_behavior = RBLPopoverBehaviorApplicationDefined;
	_animates = YES;
	_fadeDuration = 0.3;
	
	return self;
}

- (void)dealloc {
	[self.popoverWindow close];
}

#pragma mark -
#pragma mark Derived Properties

- (BOOL)isShown {
	return self.popoverWindow.isVisible;
}

#pragma mark -
#pragma mark Showing

- (void)showRelativeToRect:(CGRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(CGRectEdge)preferredEdge {
	if (CGRectEqualToRect(positioningRect, CGRectZero)) {
		positioningRect = [positioningView bounds];
	}
	
	NSRect windowRelativeRect = [positioningView convertRect:positioningRect toView:nil];
	CGRect screenRect = [positioningView.window convertRectToScreen:windowRelativeRect];
	
	self.backgroundView.popoverOrigin = screenRect;
	self.backgroundView.popoverAnchorPoint = self.anchorPoint;

	self.originalViewSize = self.contentViewController.view.frame.size;
	CGSize contentViewSize = (CGSizeEqualToSize(self.contentSize, CGSizeZero) ? self.contentViewController.view.frame.size : self.contentSize);
	
	CGPoint anchorPoint = self.anchorPoint;
	CGRect (^popoverRectForEdge)(CGRectEdge) = ^(CGRectEdge popoverEdge) {
		CGSize popoverSize = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
		CGRect returnRect = NSMakeRect(0.0, 0.0, popoverSize.width, popoverSize.height);
		
		// In all the cases below, find the minimum and maximum position of the
		// popover and then use the anchor point to determine where the popover
		// should be between these two locations.
		//
		// `x0` indicates the x origin of the popover if `self.anchorPoint.x` is
		// 0 and aligns the left edge of the popover to the left edge of the
		// origin view. `x1` is the x origin if `self.anchorPoint.x` is 1 and
		// aligns the right edge of the popover to the right edge of the origin
		// view. The anchor point determines where the popover should be between
		// these extremes.
		if (popoverEdge == CGRectMinYEdge) {
			CGFloat x0 = NSMinX(screenRect);
			CGFloat x1 = NSMaxX(screenRect) - contentViewSize.width;
			returnRect.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
			returnRect.origin.y = NSMinY(screenRect) - popoverSize.height;
		} else if (popoverEdge == CGRectMaxYEdge) {
			CGFloat x0 = NSMinX(screenRect);
			CGFloat x1 = NSMaxX(screenRect) - contentViewSize.width;
			returnRect.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
			returnRect.origin.y = NSMaxY(screenRect);
		} else if (popoverEdge == CGRectMinXEdge) {
			CGFloat y0 = NSMinY(screenRect);
			CGFloat y1 = NSMaxY(screenRect) - contentViewSize.height;
			returnRect.origin.x = NSMinX(screenRect) - popoverSize.width;
			returnRect.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
		} else if (popoverEdge == CGRectMaxXEdge) {
			CGFloat y0 = NSMinY(screenRect);
			CGFloat y1 = NSMaxY(screenRect) - contentViewSize.height;
			returnRect.origin.x = NSMaxX(screenRect);
			returnRect.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
		} else {
			returnRect = CGRectZero;
		}
		
		return returnRect;
	};
	
	BOOL (^checkPopoverSizeForScreenWithPopoverEdge)(CGRectEdge) = ^(CGRectEdge popoverEdge) {
		CGRect popoverRect = popoverRectForEdge(popoverEdge);
		return NSContainsRect(positioningView.window.screen.visibleFrame, popoverRect);
	};
	
	//This is as ugly as sin… but it gets the job done. I couldn't think of a nice way to code this but still get the desired behavior
	__block CGRectEdge popoverEdge = preferredEdge;
	CGRect (^popoverRect)() = ^{
		CGRectEdge (^nextEdgeForEdge)(CGRectEdge) = ^CGRectEdge (CGRectEdge currentEdge)
		{
			if (currentEdge == CGRectMaxXEdge) {
				return (preferredEdge == CGRectMinXEdge ? CGRectMaxYEdge : CGRectMinXEdge);
			} else if (currentEdge == CGRectMinXEdge) {
				return (preferredEdge == CGRectMaxXEdge ? CGRectMaxYEdge : CGRectMaxXEdge);
			} else if (currentEdge == CGRectMaxYEdge) {
				return (preferredEdge == CGRectMinYEdge ? CGRectMaxXEdge : CGRectMinYEdge);
			} else if (currentEdge == CGRectMinYEdge) {
				return (preferredEdge == CGRectMaxYEdge ? CGRectMaxXEdge : CGRectMaxYEdge);
			}
			
			return currentEdge;
		};
		
		CGRect (^fitRectToScreen)(CGRect) = ^CGRect (CGRect proposedRect) {
			NSRect screenRect = positioningView.window.screen.visibleFrame;
			
			if (proposedRect.origin.y < NSMinY(screenRect)) {
				proposedRect.origin.y = NSMinY(screenRect);
			}
			if (proposedRect.origin.x < NSMinX(screenRect)) {
				proposedRect.origin.x = NSMinX(screenRect);
			}
			
			if (NSMaxY(proposedRect) > NSMaxY(screenRect)) {
				proposedRect.origin.y = (NSMaxY(screenRect) - NSHeight(proposedRect));
			}
			if (NSMaxX(proposedRect) > NSMaxX(screenRect)) {
				proposedRect.origin.x = (NSMaxX(screenRect) - NSWidth(proposedRect));
			}
			
			return proposedRect;
		};
		
		NSUInteger attemptCount = 0;
		while (!checkPopoverSizeForScreenWithPopoverEdge(popoverEdge)) {
			if (attemptCount >= 4) {
				popoverEdge = preferredEdge;
				CGRect proposedRect = popoverRectForEdge(popoverEdge);
				BOOL medianYOffscreen = (preferredEdge == CGRectMinYEdge || preferredEdge == CGRectMaxYEdge) && NSMinY(proposedRect) < 0;
				BOOL medianXOffscreen = (preferredEdge == CGRectMinXEdge || preferredEdge == CGRectMaxXEdge) && NSMinX(proposedRect) < 0;
				if (medianYOffscreen || medianXOffscreen) {
					popoverEdge = nextEdgeForEdge(popoverEdge);
				}

				self.backgroundView.didOffsetFrame = YES;
				return fitRectToScreen(popoverRectForEdge(popoverEdge));
				break;
			}
			
			popoverEdge = nextEdgeForEdge(popoverEdge);
			attemptCount ++;
		}

		self.backgroundView.didOffsetFrame = NO;
		return popoverRectForEdge(popoverEdge);
	};
	
	CGRect popoverScreenRect = popoverRect();

	
	if (self.shown) {
		if (self.backgroundView.popoverEdge == popoverEdge) {
			CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
			self.backgroundView.frame = (NSRect){ .size = size };
			self.backgroundView.popoverEdge = popoverEdge;
			[self.popoverWindow setFrame:popoverScreenRect display:YES];

			return;
		}
		
		[self.popoverWindow close];
		self.popoverWindow = nil;
	}
	
	//TODO: Create RBLViewController with viewWillAppear
	//[self.contentViewController viewWillAppear:YES]; //this will always be animated… in the current implementation
	
	if (self.willShowBlock != nil) self.willShowBlock(self);
	
	if (self.behavior != NSPopoverBehaviorApplicationDefined) {
		[self removeEventMonitors];
				
		__weak RBLPopover *weakSelf = self;
		void (^monitor)(NSEvent *event) = ^(NSEvent *event) {
			RBLPopover *strongSelf = weakSelf;
			if (strongSelf.popoverWindow == nil) return;
			BOOL shouldClose = NO;
			BOOL mouseInPopoverWindow = NSPointInRect(NSEvent.mouseLocation, strongSelf.popoverWindow.frame);
			if (strongSelf.behavior == RBLPopoverBehaviorTransient) {
				shouldClose = !mouseInPopoverWindow;
			} else {
				shouldClose = strongSelf.popoverWindow.parentWindow.isKeyWindow && NSPointInRect(NSEvent.mouseLocation, strongSelf.popoverWindow.parentWindow.frame) && !mouseInPopoverWindow;
			}
			
			if (shouldClose) [strongSelf close];
		};
		
		NSInteger mask = 0;
		if (self.behavior == RBLPopoverBehaviorTransient) {
			mask = NSLeftMouseDownMask | NSRightMouseDownMask;
		} else {
			mask = NSLeftMouseUpMask | NSRightMouseUpMask;
		}
		
		NSMutableSet *newMonitors = [[NSMutableSet alloc] init];
		if (self.behavior == RBLPopoverBehaviorTransient) {
			[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appResignedActive:) name:NSApplicationDidResignActiveNotification object:NSApp];
			id globalMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:monitor];
			[newMonitors addObject:globalMonitor];
		}
		
		id localMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:mask handler:^(NSEvent *event) {
			monitor(event);
			return event;
		}];
		[newMonitors addObject:localMonitor];
		self.transientEventMonitors = newMonitors;
	}
	
	CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
	self.backgroundView.frame = (NSRect){ .size = size };
	self.backgroundView.popoverEdge = popoverEdge;
	
	CGRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:self.backgroundView.bounds popoverEdge:popoverEdge];
	self.contentViewController.view.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
	self.contentViewController.view.frame = contentViewFrame;
	[self.backgroundView addSubview:self.contentViewController.view positioned:NSWindowBelow relativeTo:nil];
	self.popoverWindow = [[RBLPopoverWindow alloc] initWithContentRect:popoverScreenRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	self.popoverWindow.hasShadow = YES;
	self.popoverWindow.releasedWhenClosed = NO;
	self.popoverWindow.opaque = NO;
	self.popoverWindow.backgroundColor = NSColor.clearColor;
	self.popoverWindow.contentView = self.backgroundView;
	self.popoverWindow.canBeKey = self.canBecomeKey;
	if (self.animates) {
		self.popoverWindow.alphaValue = 0.0;
	}

	// We're using a dummy button to capture the escape key equivalent when it
	// isn't handled by the first responder. This is bad and I feel bad.
	NSButton *closeButton = [[NSButton alloc] initWithFrame:CGRectMake(-1, -1, 0, 0)];
	closeButton.keyEquivalent = @"\E";
	closeButton.target = self;
	closeButton.action = @selector(performClose:);
	[self.popoverWindow.contentView addSubview:closeButton];
	
	[positioningView.window addChildWindow:self.popoverWindow ordered:NSWindowAbove];
	[self.popoverWindow makeKeyAndOrderFront:self];
	
	void (^postDisplayBlock)(void) = ^{		
		if (self.didShowBlock != NULL) self.didShowBlock(self);
	};
	
	if (self.animates) {
		[NSView rbl_animateWithDuration:self.fadeDuration animations:^{
			[self.popoverWindow.animator setAlphaValue:1.0];
		} completion:postDisplayBlock];
	} else {
		postDisplayBlock();
	}
}

#pragma mark -
#pragma mark Closing

- (void)close {
	if (!self.shown) return;
	
	[self removeEventMonitors];
	
	if (self.willCloseBlock != nil) self.willCloseBlock(self);
	
	void (^windowTeardown)(void) = ^{
		[self.popoverWindow.parentWindow removeChildWindow:self.popoverWindow];
		[self.popoverWindow close];
		
		if (self.didCloseBlock != nil) self.didCloseBlock(self);
		
		self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, self.contentViewController.view.frame.origin.y, self.originalViewSize.width, self.originalViewSize.height);
	};
	
	if (self.animates) {
		[NSView rbl_animateWithDuration:self.fadeDuration animations:^{
			[self.popoverWindow.animator setAlphaValue:0.0];
		} completion:windowTeardown];
	} else {
		windowTeardown();
	}
}

- (IBAction)performClose:(id)sender {
	[self close];
}

#pragma mark -
#pragma mark Event Monitor

- (void)removeEventMonitors {
	for (id eventMonitor in self.transientEventMonitors) {
		[NSEvent removeMonitor:eventMonitor];
	}
	self.transientEventMonitors = nil;
	[NSNotificationCenter.defaultCenter removeObserver:self name:NSApplicationDidResignActiveNotification object:NSApp];
	[NSNotificationCenter.defaultCenter removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
}

- (void)appResignedActive:(NSNotification *)notification {
	if (self.behavior == RBLPopoverBehaviorTransient) [self close];
}

@end

//***************************************************************************

static CGFloat const RBLPopoverBackgroundViewBorderRadius = 5.0;
static CGFloat const RBLPopoverBackgroundViewArrowHeight = 17.0;
static CGFloat const RBLPopoverBackgroundViewArrowWidth = 35.0;

//***************************************************************************

@implementation RBLPopoverBackgroundView

- (CGSize)sizeForBackgroundViewWithContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge {
	CGSize returnSize = contentSize;
	if (popoverEdge == CGRectMaxXEdge || popoverEdge == CGRectMinXEdge) {
		returnSize.width += self.arrowSize.height;
	} else {
		returnSize.height += self.arrowSize.height;
	}
	
	returnSize.width += 2.0;
	returnSize.height += 2.0;
	
	return returnSize;
}

- (CGRect)contentViewFrameForBackgroundFrame:(CGRect)backgroundFrame popoverEdge:(CGRectEdge)popoverEdge {
	CGRect returnFrame = NSInsetRect(backgroundFrame, 1.0, 1.0);
	switch (popoverEdge) {
		case CGRectMinXEdge:
			returnFrame.size.width -= self.arrowSize.height;
			break;
		case CGRectMinYEdge:
			returnFrame.size.height -= self.arrowSize.height;
			break;
		case CGRectMaxXEdge:
			returnFrame.size.width -= self.arrowSize.height;
			returnFrame.origin.x += self.arrowSize.height;
			break;
		case CGRectMaxYEdge:
			returnFrame.size.height -= self.arrowSize.height;
			returnFrame.origin.y += self.arrowSize.height;
			break;
		default:
			NSAssert(NO, @"Failed to pass in a valid CGRectEdge");
			break;
	}
	
	return returnFrame;
}

- (CGPathRef)newPopoverPathForEdge:(CGRectEdge)popoverEdge inFrame:(CGRect)frame {
	CGRectEdge arrowEdge = [self rbl_arrowEdgeForPopoverEdge:popoverEdge];
	
	CGRect contentRect = CGRectIntegral([self contentViewFrameForBackgroundFrame:frame popoverEdge:self.popoverEdge]);
	CGFloat minX = NSMinX(contentRect);
	CGFloat maxX = NSMaxX(contentRect);
	CGFloat minY = NSMinY(contentRect);
	CGFloat maxY = NSMaxY(contentRect);

	CGFloat midOriginY = floor(NSMaxY(contentRect) * self.popoverAnchorPoint.y);
	CGFloat midOriginX = floor(NSMaxX(contentRect) * self.popoverAnchorPoint.x);
	if (self.didOffsetFrame) {
	   CGRect windowRect = [self.window convertRectFromScreen:self.popoverOrigin];
	   CGRect originRect = [self convertRect:windowRect fromView:nil];
		midOriginX = floor(RBLRectsGetMedianX(originRect, contentRect));
		midOriginY = floor(RBLRectsGetMedianY(originRect, contentRect));
	}
	
	CGFloat maxArrowX = 0.0;
	CGFloat minArrowX = 0.0;
	CGFloat minArrowY = 0.0;
	CGFloat maxArrowY = 0.0;
	
	// Even I have no idea at this point… :trollface:
	// So we don't have a weird arrow situation we need to make sure we draw it within the radius.
	// If we have to nudge it then we have to shrink the arrow as otherwise it looks all wonky and weird.
	// That is what this complete mess below does.
	
	if (arrowEdge == CGRectMinYEdge || arrowEdge == CGRectMaxYEdge) {
		maxArrowX = floor(midOriginX + (self.arrowSize.width / 2.0));
		CGFloat maxPossible = (NSMaxX(contentRect) - RBLPopoverBackgroundViewBorderRadius);
		if (maxArrowX > maxPossible) {
			maxArrowX = maxPossible;
			minArrowX = maxArrowX - self.arrowSize.width;
		} else {
			minArrowX = floor(midOriginX - (self.arrowSize.width / 2.0));
			if (minArrowX < RBLPopoverBackgroundViewBorderRadius) {
				minArrowX = RBLPopoverBackgroundViewBorderRadius;
				maxArrowX = minArrowX + self.arrowSize.width;
			}
		}
	} else {
		minArrowY = floor(midOriginY - (self.arrowSize.width / 2.0));
		if (minArrowY < RBLPopoverBackgroundViewBorderRadius) {
			minArrowY = RBLPopoverBackgroundViewBorderRadius;
			maxArrowY = minArrowY + self.arrowSize.width;
		} else {
			maxArrowY = floor(midOriginY + (self.arrowSize.width / 2.0));
			CGFloat maxPossible = (NSMaxY(contentRect) - RBLPopoverBackgroundViewBorderRadius);
			if (maxArrowY > maxPossible) {
				maxArrowY = maxPossible;
				minArrowY = maxArrowY - self.arrowSize.width;
			}
		}
	}
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, minX, floor(minY + RBLPopoverBackgroundViewBorderRadius));

	
	CGPathAddArc(path, NULL, floor(minX + RBLPopoverBackgroundViewBorderRadius), floor(minY + contentRect.size.height - RBLPopoverBackgroundViewBorderRadius), RBLPopoverBackgroundViewBorderRadius, M_PI, M_PI / 2, 1);

	
	CGPathAddArc(path, NULL, floor(minX + contentRect.size.width - RBLPopoverBackgroundViewBorderRadius), floor(minY + contentRect.size.height - RBLPopoverBackgroundViewBorderRadius), RBLPopoverBackgroundViewBorderRadius, M_PI / 2, 0.0, 1);

	
	CGPathAddArc(path, NULL, floor(contentRect.origin.x + contentRect.size.width - RBLPopoverBackgroundViewBorderRadius), floor(minY + RBLPopoverBackgroundViewBorderRadius), RBLPopoverBackgroundViewBorderRadius, 0.0, -M_PI / 2, 1);
	
	CGPathAddArc(path, NULL, floor(minX + RBLPopoverBackgroundViewBorderRadius), floor(minY + RBLPopoverBackgroundViewBorderRadius), RBLPopoverBackgroundViewBorderRadius, -M_PI / 2, M_PI, 1);

	CGFloat x1, x2, x3, y1, y2, y3;
	switch (arrowEdge) {
		case CGRectMinXEdge:
			x1 = minX, y1 = minArrowY;
			x2 = floor(minX - self.arrowSize.height), y2 = midOriginY;
			x3 = minX, y3 = maxArrowY;
			break;
		case CGRectMaxYEdge:
			x1 = minArrowX, y1 = maxY;
			x2 = floor((minArrowX + maxArrowX) / 2), y2 = floor(maxY + self.arrowSize.height);
			x3 = maxArrowX, y3 = maxY;
			break;
		case CGRectMaxXEdge:
			x1 = maxX, y1 = maxArrowY;
			x2 = floor(maxX + self.arrowSize.height), y2 = midOriginY;
			x3 = maxX, y3 = minArrowY;
			break;
		case CGRectMinYEdge:
			x1 = maxArrowX, y1 = minY;
			x2 = floor((minArrowX + maxArrowX) / 2), y2 = floor(minY - self.arrowSize.height);
			x3 = minArrowX, y3 = minY;
			break;
		default:
			break;
	}

	CGPathMoveToPoint(path, NULL, x1, y1);
	CGPathAddLineToPoint(path, NULL, x1, y1);
	CGPathAddLineToPoint(path, NULL, x2, y2);
	CGPathAddLineToPoint(path, NULL, x3, y3);
	
	return path;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;
	
	_arrowSize = CGSizeMake(RBLPopoverBackgroundViewArrowWidth, RBLPopoverBackgroundViewArrowHeight);
	_fillColor = NSColor.whiteColor;
	
	_rbl_clippingView = [[RBLPopoverClippingView alloc] initWithFrame:self.bounds];
	self.rbl_clippingView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self addSubview:self.rbl_clippingView];
	
	return self;
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];
	[self rbl_updateClippingView];
}

- (void)setArrowSize:(CGSize)arrowSize {
	if (CGSizeEqualToSize(arrowSize, self.arrowSize)) return;
	_arrowSize = arrowSize;
	[self rbl_updateClippingView];
}

- (void)setPopoverEdge:(CGRectEdge)popoverEdge {
	if (popoverEdge == self.popoverEdge) return;
	_popoverEdge = popoverEdge;
	[self rbl_updateClippingView];
}

- (void)setPopoverOrigin:(NSRect)popoverOrigin {
	if (NSEqualRects(popoverOrigin, self.popoverOrigin)) return;
	_popoverOrigin = popoverOrigin;
	[self rbl_updateClippingView];
}

- (void)setPopoverAnchorPoint:(NSPoint)popoverAnchorPoint {
	if (NSEqualPoints(popoverAnchorPoint, self.popoverAnchorPoint)) return;
	_popoverAnchorPoint = popoverAnchorPoint;
	[self rbl_updateClippingView];
}

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	[self.fillColor set];
	NSRectFill(rect);
}

- (BOOL)isOpaque {
	return NO;
}

- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
	[self rbl_updateClippingView];
}

#pragma mark - Private Methods

- (CGRectEdge)rbl_arrowEdgeForPopoverEdge:(CGRectEdge)popoverEdge {
	CGRectEdge arrowEdge = CGRectMinYEdge;
	switch (popoverEdge) {
		case CGRectMaxXEdge:
			arrowEdge = CGRectMinXEdge;
			break;
		case CGRectMaxYEdge:
			arrowEdge = CGRectMinYEdge;
			break;
		case CGRectMinXEdge:
			arrowEdge = CGRectMaxXEdge;
			break;
		case CGRectMinYEdge:
			arrowEdge = CGRectMaxYEdge;
			break;
		default:
			break;
	}
	
	return arrowEdge;
}

- (void)rbl_updateClippingView {
	// There's no point if it's not in a window
	if (self.window == nil) return;
	CGPathRef clippingPath = [self newPopoverPathForEdge:self.popoverEdge inFrame:self.rbl_clippingView.bounds];
	self.rbl_clippingView.clippingPath = clippingPath;
	CGPathRelease(clippingPath);
}

@end

//
//  RBLPopover.m
//  Rebel
//
//  Created by Danny Greg on 13/09/2012.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLPopover.h"

#import "CAAnimation+RBLBlockAdditions.h"
#import "NSColor+RBLCGColorAdditions.h"

#import <QuartzCore/QuartzCore.h>
#import "EXTKeyPathCoding.h"

//***************************************************************************

@interface RBLPopoverBackgroundView ()

@property (nonatomic) CGRect screenOriginRect;

+ (instancetype)backgroundViewForContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect;

- (CGRectEdge)arrowEdgeForPopoverEdge:(CGRectEdge)popoverEdge;

@end

//***************************************************************************

static NSTimeInterval const RBLPopoverDefaultFadeDuration = 0.3;

//***************************************************************************

@interface RBLPopover ()

// The window we are using to display the popover.
@property (nonatomic, strong) NSWindow *popoverWindow;

// The identifier for the event monitor we are using to watch for mouse clicks
// outisde of the popover.
// We are not responsible for it's memory management.
@property (nonatomic, weak) id transientEventMonitor;

// Whether the popover is currently animating, either in or out.
@property (nonatomic, getter = isAnimating) BOOL animating;

// The size the content view was before the popover was shown.
@property (nonatomic) CGSize originalViewSize;

// Correctly removes our event monitor watching for mouse clicks external to the
// popover.
- (void)removeEventMonitor;

@end

//***************************************************************************

@interface RBLPopoverClippingView : NSView

@property (nonatomic) CGPathRef clippingPath;

@end

@implementation RBLPopoverClippingView

- (void)setClippingPath:(CGPathRef)clippingPath {
	if (clippingPath == _clippingPath) return;
	
	CGPathRelease(_clippingPath);
	_clippingPath = clippingPath;
	CGPathRetain(_clippingPath);
}

- (void)drawRect:(NSRect)dirtyRect {
	if (self.clippingPath == nil) return;
	
	CGContextRef currentContext = NSGraphicsContext.currentContext.graphicsPort;
	CGContextAddRect(currentContext, self.bounds);
	CGContextAddPath(currentContext, self.clippingPath);
	CGContextSetBlendMode(currentContext, kCGBlendModeCopy);
	[NSColor.clearColor set];
	CGContextEOFillPath(currentContext);
}

@end

//***************************************************************************

@implementation RBLPopover

- (instancetype)initWithContentViewController:(NSViewController *)viewController {
	self = [super init];
	if (self == nil)
		return nil;
	
	_contentViewController = viewController;
	_backgroundViewClass = RBLPopoverBackgroundView.class;
	_behavior = RBLPopoverViewControllerBehaviorApplicationDefined;
	_animates = YES;
	
	return self;
}

#pragma mark -
#pragma mark Derived Properties

- (BOOL)isShown {
	return self.popoverWindow.isVisible;
}

#pragma mark -
#pragma mark Showing

- (void)showRelativeToRect:(CGRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(CGRectEdge)preferredEdge {
	if (self.shown) return;
	
	//TODO: Create RBLViewController with viewWillAppear
	//[self.contentViewController viewWillAppear:YES]; //this will always be animated… in the current implementation
	
	if (self.willShowBlock != nil) self.willShowBlock(self);
	
	if (self.behavior != RBLPopoverViewControllerBehaviorApplicationDefined) {
		[self removeEventMonitor];
		
		self.transientEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSKeyUpMask) handler: ^(NSEvent *event) {
			if (self.popoverWindow == nil) return event;
			
			static NSUInteger escapeKey = 53;
			BOOL shouldClose = NO;
			if (event.type == NSLeftMouseDown || event.type == NSRightMouseDown) {
				shouldClose = (!NSPointInRect(NSEvent.mouseLocation, self.popoverWindow.frame) && self.behavior == RBLPopoverViewControllerBehaviorTransient);
			} else {
				shouldClose = (event.keyCode == escapeKey);
			}
			
			if (shouldClose) [self close];
			
			return event;
		}];
	}
	
	if (CGRectEqualToRect(positioningRect, CGRectZero)) {
		positioningRect = [positioningView bounds];
	}
	
	NSRect windowRelativeRect = [positioningView convertRect:positioningRect toView:nil];
	CGRect screenPositioningRect = [positioningView.window convertRectToScreen:windowRelativeRect];
	self.originalViewSize = self.contentViewController.view.frame.size;
	CGSize contentViewSize = (CGSizeEqualToSize(self.contentSize, CGSizeZero) ? self.contentViewController.view.frame.size : self.contentSize);
	
	CGRect (^popoverRectForEdge)(CGRectEdge) = ^(CGRectEdge popoverEdge) {
		CGSize popoverSize = [self.backgroundViewClass sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
		CGRect returnRect = NSMakeRect(0.0, 0.0, popoverSize.width, popoverSize.height);
		if (popoverEdge == CGRectMinYEdge) {
			CGFloat xOrigin = NSMidX(screenPositioningRect) - floor(popoverSize.width / 2.0);
			CGFloat yOrigin = NSMinY(screenPositioningRect) - popoverSize.height;
			returnRect.origin = NSMakePoint(xOrigin, yOrigin);
		} else if (popoverEdge == CGRectMaxYEdge) {
			CGFloat xOrigin = NSMidX(screenPositioningRect) - floor(popoverSize.width / 2.0);
			returnRect.origin = NSMakePoint(xOrigin, NSMaxY(screenPositioningRect));
		} else if (popoverEdge == CGRectMinXEdge) {
			CGFloat xOrigin = NSMinX(screenPositioningRect) - popoverSize.width;
			CGFloat yOrigin = NSMidY(screenPositioningRect) - floor(popoverSize.height / 2.0);
			returnRect.origin = NSMakePoint(xOrigin, yOrigin);
		} else if (popoverEdge == CGRectMaxXEdge) {
			CGFloat yOrigin = NSMidY(screenPositioningRect) - floor(popoverSize.height / 2.0);
			returnRect.origin = NSMakePoint(NSMaxX(screenPositioningRect), yOrigin);
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
				return fitRectToScreen(popoverRectForEdge(popoverEdge));
				break;
			}
			
			popoverEdge = nextEdgeForEdge(popoverEdge);
			attemptCount ++;
		}
		
		return popoverRectForEdge(popoverEdge);
	};
	
	CGRect popoverScreenRect = popoverRect();
	RBLPopoverBackgroundView *backgroundView = [self.backgroundViewClass backgroundViewForContentSize:contentViewSize popoverEdge:popoverEdge originScreenRect:screenPositioningRect];
	
	CGRect contentViewFrame = [self.backgroundViewClass contentViewFrameForBackgroundFrame:backgroundView.bounds popoverEdge:popoverEdge];
	self.contentViewController.view.frame = contentViewFrame;
	[backgroundView addSubview:self.contentViewController.view];
	self.popoverWindow = [[NSWindow alloc] initWithContentRect:popoverScreenRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	self.popoverWindow.hasShadow = YES;
	self.popoverWindow.releasedWhenClosed = NO;
	self.popoverWindow.opaque = NO;
	self.popoverWindow.backgroundColor = NSColor.clearColor;
	self.popoverWindow.contentView = backgroundView;
	if (self.animates) {
		self.popoverWindow.alphaValue = 0.0;
	}
	
	RBLPopoverClippingView *clippingView = [[RBLPopoverClippingView alloc] initWithFrame:backgroundView.bounds];
	CGPathRef clippingPath = [backgroundView newPopoverPathForEdge:popoverEdge inFrame:clippingView.bounds];
	clippingView.clippingPath = clippingPath;
	CGPathRelease(clippingPath);
	[backgroundView addSubview:clippingView];
	
	[positioningView.window addChildWindow:self.popoverWindow ordered:NSWindowAbove];
	[self.popoverWindow makeKeyAndOrderFront:self];
	
	void (^postDisplayBlock)(BOOL) = ^(BOOL finished) {
		self.animating = NO;
		//[self.contentViewController viewDidAppear:YES];
		
		if (self.didShowBlock) self.didShowBlock(self);
	};
	
	if (self.animates) {
		CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@keypath(_popoverWindow.alphaValue)];
		fadeInAnimation.duration = RBLPopoverDefaultFadeDuration;
		fadeInAnimation.rbl_completionBlock = postDisplayBlock;
		
		self.popoverWindow.animations = @{ @keypath(_popoverWindow.alphaValue): fadeInAnimation };
		self.animating = YES;
		[self.popoverWindow.animator setAlphaValue:1.0];
	} else {
		postDisplayBlock(YES);
	}
}

#pragma mark -
#pragma mark Closing

- (void)close {
	[self closeWithFadeoutDuration:RBLPopoverDefaultFadeDuration];
}

- (void)closeWithFadeoutDuration:(NSTimeInterval)duration {
	if (self.animating || !self.shown) return;
	
	[self removeEventMonitor];
	
	if (self.willCloseBlock != nil) self.willCloseBlock(self);
	
	void (^windowTeardown)(BOOL) = ^(BOOL finished) {
		[self.popoverWindow.parentWindow removeChildWindow:self.popoverWindow];
		[self.popoverWindow close];
		self.animating = NO;
		
		if (self.didCloseBlock != nil) self.didCloseBlock(self);
		
		self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, self.contentViewController.view.frame.origin.y, self.originalViewSize.width, self.originalViewSize.height);
	};
	
	if (self.animates) {
		CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@keypath(_popoverWindow.alphaValue)];
		fadeOutAnimation.duration = duration;
		fadeOutAnimation.rbl_completionBlock = windowTeardown;
		
		self.popoverWindow.animations = @{ @keypath(_popoverWindow.alphaValue): fadeOutAnimation };
		self.animating = YES;
		[self.popoverWindow.animator setAlphaValue:0.0];
	} else {
		windowTeardown(YES);
	}
}

- (IBAction)performClose:(id)sender {
	[self close];
}

#pragma mark -
#pragma mark Event Monitor

- (void)removeEventMonitor {
	if (self.transientEventMonitor == nil) return;
	[NSEvent removeMonitor:self.transientEventMonitor];
	self.transientEventMonitor = nil;
}

@end

//***************************************************************************

static CGFloat const RBLPopoverBackgroundViewBorderRadius = 5.0;
static CGFloat const RBLPopoverBackgroundViewArrowHeight = 17.0;
static CGFloat const RBLPopoverBackgroundViewArrowWidth = 35.0;

//***************************************************************************

@implementation RBLPopoverBackgroundView

+ (CGSize)sizeForBackgroundViewWithContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge {
	CGSize returnSize = contentSize;
	if (popoverEdge == CGRectMaxXEdge || popoverEdge == CGRectMinXEdge) {
		returnSize.width += RBLPopoverBackgroundViewArrowHeight;
	} else {
		returnSize.height += RBLPopoverBackgroundViewArrowHeight;
	}
	
	returnSize.width ++;
	returnSize.height ++;
	
	return returnSize;
}

+ (CGRect)contentViewFrameForBackgroundFrame:(CGRect)backgroundFrame popoverEdge:(CGRectEdge)popoverEdge {
	CGRect returnFrame = NSInsetRect(backgroundFrame, 1.0, 1.0);
	switch (popoverEdge) {
		case CGRectMinXEdge:
			returnFrame.size.width -= RBLPopoverBackgroundViewArrowHeight;
			break;
		case CGRectMinYEdge:
			returnFrame.size.height -= RBLPopoverBackgroundViewArrowHeight;
			break;
		case CGRectMaxXEdge:
			returnFrame.size.width -= RBLPopoverBackgroundViewArrowHeight;
			returnFrame.origin.x += RBLPopoverBackgroundViewArrowHeight;
			break;
		case CGRectMaxYEdge:
			returnFrame.size.height -= RBLPopoverBackgroundViewArrowHeight;
			returnFrame.origin.y += RBLPopoverBackgroundViewArrowHeight;
			break;
		default:
			NSAssert(NO, @"Failed to pass in a valid CGRectEdge");
			break;
	}
	
	return returnFrame;
}

+ (instancetype)backgroundViewForContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect {
	CGSize size = [self sizeForBackgroundViewWithContentSize:contentSize popoverEdge:popoverEdge];
	RBLPopoverBackgroundView *returnView = [[self.class alloc] initWithFrame:NSMakeRect(0.0, 0.0, size.width, size.height) popoverEdge:popoverEdge originScreenRect:originScreenRect];
	return returnView;
}

- (CGPathRef)newPopoverPathForEdge:(CGRectEdge)popoverEdge inFrame:(CGRect)frame {
	CGRectEdge arrowEdge = [self arrowEdgeForPopoverEdge:popoverEdge];
	
	CGRect contentRect = CGRectIntegral([self.class contentViewFrameForBackgroundFrame:frame popoverEdge:self.popoverEdge]);
	CGFloat minX = NSMinX(contentRect);
	CGFloat maxX = NSMaxX(contentRect);
	CGFloat minY = NSMinY(contentRect);
	CGFloat maxY = NSMaxY(contentRect);

	CGRect windowRect = [self.window convertRectFromScreen:self.screenOriginRect];
	CGRect originRect = [self convertRect:windowRect fromView:nil];
	CGFloat midOriginY = floor(NSMidY(originRect));
	CGFloat midOriginX = floor(NSMidX(originRect));
	
	CGFloat maxArrowX = 0.0;
	CGFloat minArrowX = 0.0;
	CGFloat minArrowY = 0.0;
	CGFloat maxArrowY = 0.0;
	
	// Even I have no idea at this point… :trollface:
	// So we don't have a weird arrow situation we need to make sure we draw it within the radius.
	// If we have to nudge it then we have to shrink the arrow as otherwise it looks all wonky and weird.
	// That is what this complete mess below does.
	
	if (arrowEdge == CGRectMinYEdge || arrowEdge == CGRectMaxYEdge) {
		maxArrowX = floor(midOriginX + (RBLPopoverBackgroundViewArrowWidth / 2.0));
		CGFloat maxPossible = (NSMaxX(contentRect) - RBLPopoverBackgroundViewBorderRadius);
		if (maxArrowX > maxPossible) {
			CGFloat delta = maxArrowX - maxPossible;
			maxArrowX = maxPossible;
			minArrowX = maxArrowX - (RBLPopoverBackgroundViewArrowWidth - delta);
		} else {
			minArrowX = floor(midOriginX - (RBLPopoverBackgroundViewArrowWidth / 2.0));
			if (minArrowX < RBLPopoverBackgroundViewBorderRadius) {
				CGFloat delta = RBLPopoverBackgroundViewBorderRadius - minArrowX;
				minArrowX = RBLPopoverBackgroundViewBorderRadius;
				maxArrowX = minArrowX + (RBLPopoverBackgroundViewArrowWidth - (delta * 2));
			}
		}
	} else {
		minArrowY = floor(midOriginY - (RBLPopoverBackgroundViewArrowWidth / 2.0));
		if (minArrowY < RBLPopoverBackgroundViewBorderRadius) {
			CGFloat delta = RBLPopoverBackgroundViewBorderRadius - minArrowY;
			minArrowY = RBLPopoverBackgroundViewBorderRadius;
			maxArrowY = minArrowY + (RBLPopoverBackgroundViewArrowWidth - (delta * 2));
		} else {
			maxArrowY = floor(midOriginY + (RBLPopoverBackgroundViewArrowWidth / 2.0));
			CGFloat maxPossible = (NSMaxY(contentRect) - RBLPopoverBackgroundViewBorderRadius);
			if (maxArrowY > maxPossible) {
				CGFloat delta = maxArrowY - maxPossible;
				maxArrowY = maxPossible;
				minArrowY = maxArrowY - (RBLPopoverBackgroundViewArrowWidth - delta);
			}
		}
	}
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, minX, floor(minY + RBLPopoverBackgroundViewBorderRadius));
	if (arrowEdge == CGRectMinXEdge) {
		CGPathAddLineToPoint(path, NULL, minX, minArrowY);
		CGPathAddLineToPoint(path, NULL, floor(minX - RBLPopoverBackgroundViewArrowHeight), midOriginY);
		CGPathAddLineToPoint(path, NULL, minX, maxArrowY);
	}
	
	CGPathAddArc(path, NULL, floor(minX + RBLPopoverBackgroundViewBorderRadius), floor(minY + contentRect.size.height - RBLPopoverBackgroundViewBorderRadius), RBLPopoverBackgroundViewBorderRadius, M_PI, M_PI / 2, 1);
	if (arrowEdge == CGRectMaxYEdge) {
		CGPathAddLineToPoint(path, NULL, minArrowX, maxY);
		CGPathAddLineToPoint(path, NULL, midOriginX, floor(maxY + RBLPopoverBackgroundViewArrowHeight));
		CGPathAddLineToPoint(path, NULL, maxArrowX, maxY);
	}
	
	CGPathAddArc(path, NULL, floor(minX + contentRect.size.width - RBLPopoverBackgroundViewBorderRadius), floor(minY + contentRect.size.height - RBLPopoverBackgroundViewBorderRadius), RBLPopoverBackgroundViewBorderRadius, M_PI / 2, 0.0, 1);
	if (arrowEdge == CGRectMaxXEdge) {
		CGPathAddLineToPoint(path, NULL, maxX, maxArrowY);
		CGPathAddLineToPoint(path, NULL, floor(maxX + RBLPopoverBackgroundViewArrowHeight), midOriginY);
		CGPathAddLineToPoint(path, NULL, maxX, minArrowY);
	}
	
	CGPathAddArc(path, NULL, floor(contentRect.origin.x + contentRect.size.width - RBLPopoverBackgroundViewBorderRadius), floor(minY + RBLPopoverBackgroundViewBorderRadius), RBLPopoverBackgroundViewBorderRadius, 0.0, -M_PI / 2, 1);
	if (arrowEdge == CGRectMinYEdge) {
		CGPathAddLineToPoint(path, NULL, maxArrowX, minY);
		CGPathAddLineToPoint(path, NULL, midOriginX, floor(minY - RBLPopoverBackgroundViewArrowHeight));
		CGPathAddLineToPoint(path, NULL, minArrowX, minY);
	}
	
	CGPathAddArc(path, NULL, floor(minX + RBLPopoverBackgroundViewBorderRadius), floor(minY + RBLPopoverBackgroundViewBorderRadius), RBLPopoverBackgroundViewBorderRadius, -M_PI / 2, M_PI, 1);
	
	return path;
}

- (instancetype)initWithFrame:(CGRect)frame popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;
	
	_popoverEdge = popoverEdge;
	_screenOriginRect = originScreenRect;
	_strokeColor = NSColor.redColor;
	_fillColor = NSColor.whiteColor;
	
	return self;
}

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
	CGPathRef outerBorder = [self newPopoverPathForEdge:self.popoverEdge inFrame:self.bounds];
	CGContextSetFillColorWithColor(context, self.fillColor.rbl_CGColor);
	CGContextAddPath(context, outerBorder);
	CGContextFillPath(context);
	
	CGPathRelease(outerBorder);
}

- (CGRectEdge)arrowEdgeForPopoverEdge:(CGRectEdge)popoverEdge {
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

- (BOOL)isOpaque {
	return NO;
}

@end

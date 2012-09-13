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

//***************************************************************************

@interface RBLPopoverBackgroundView ()

@property (nonatomic) CGRect screenOriginRect;
@property (nonatomic) CGRectEdge popoverEdge;

- (CGRectEdge)arrowEdgeForPopoverEdge:(CGRectEdge)popoverEdge;
- (void)updateMaskLayer;

@end

//***************************************************************************

@interface RBLPopoverWindowContentView : NSView

@property (nonatomic, unsafe_unretained) CGRectEdge arrowEdge;

@end

//***************************************************************************

NSTimeInterval const RBLPopoverDefaultFadeoutDuration = 0.3;

//***************************************************************************

@interface RBLPopover ()

@property (nonatomic, strong) NSWindow *popoverWindow;
@property (nonatomic, unsafe_unretained) id transientEventMonitor;
@property (nonatomic) BOOL animating;
@property (nonatomic) CGSize originalViewSize;

- (void)removeEventMonitor;

@end

//***************************************************************************

@implementation RBLPopover

- (id)initWithContentViewController:(NSViewController *)viewController
{
	self = [super init];
	if (self == nil)
		return nil;
	
    _contentViewController = viewController;
    _backgroundViewClass = RBLPopoverBackgroundView.class;
	_behaviour = RBLPopoverViewControllerBehaviourApplicationDefined;
	
	return self;
}

#pragma mark -
#pragma mark Derived Properties

- (BOOL)shown
{
    return (self.popoverWindow.contentView != nil);
}

#pragma mark -
#pragma mark Showing

- (void)showRelativeToRect:(CGRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(CGRectEdge)preferredEdge
{
    if (self.shown)
        return;
    
	//TODO: Create RBLViewController with viewWillAppear
    //[self.contentViewController viewWillAppear:YES]; //this will always be animated… in the current implementation
    
    if (self.willShowBlock != nil)
        self.willShowBlock(self);
    
    if (self.behaviour != RBLPopoverViewControllerBehaviourApplicationDefined) {
		if (self.transientEventMonitor != nil) {
			[self removeEventMonitor];
		}
		
        self.transientEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSKeyUpMask) handler: ^ (NSEvent *event) {
            if (self.popoverWindow == nil)
                return event;
			
			static NSUInteger escapeKey = 53;
			BOOL shouldClose = (event.type == NSLeftMouseDown || event.type == NSRightMouseDown ? (!NSPointInRect([NSEvent mouseLocation], self.popoverWindow.frame) && self.behaviour == RBLPopoverViewControllerBehaviourTransient) : event.keyCode == escapeKey);
            
            if (shouldClose) {
                [self close];
            }
            
            return event;
        }];
    }
	
    if (CGRectEqualToRect(positioningRect, CGRectZero))
        positioningRect = [positioningView bounds];
    
    NSRect windowRelativeRect = [positioningView convertRect:positioningRect toView:nil];
    CGRect screenPositioningRect = windowRelativeRect;
	screenPositioningRect.origin = [positioningView.window convertBaseToScreen:windowRelativeRect.origin];
    self.originalViewSize = self.contentViewController.view.frame.size;
    CGSize contentViewSize = (CGSizeEqualToSize(self.contentSize, CGSizeZero) ? self.contentViewController.view.frame.size : self.contentSize);
    
    CGRect (^popoverRectForEdge)(CGRectEdge) = ^ (CGRectEdge popoverEdge)
    {
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
	
    BOOL (^checkPopoverSizeForScreenWithPopoverEdge)(CGRectEdge) = ^ (CGRectEdge popoverEdge)
    {
        CGRect popoverRect = popoverRectForEdge(popoverEdge);
        return NSContainsRect(positioningView.window.screen.visibleFrame, popoverRect);
    };
    
    //This is as ugly as sin… but it gets the job done. I couldn't think of a nice way to code this but still get the desired behaviour
    __block CGRectEdge popoverEdge = preferredEdge;
    CGRect (^popoverRect)() = ^
    {
        CGRectEdge (^nextEdgeForEdge)(CGRectEdge) = ^ (CGRectEdge currentEdge)
        {
            if (currentEdge == CGRectMaxXEdge) {
                return (CGRectEdge)(preferredEdge == CGRectMinXEdge ? CGRectMaxYEdge : CGRectMinXEdge);
            } else if (currentEdge == CGRectMinXEdge) {
                return (CGRectEdge)(preferredEdge == CGRectMaxXEdge ? CGRectMaxYEdge : CGRectMaxXEdge);
            } else if (currentEdge == CGRectMaxYEdge) {
                return (CGRectEdge)(preferredEdge == CGRectMinYEdge ? CGRectMaxXEdge : CGRectMinYEdge);
            } else if (currentEdge == CGRectMinYEdge) {
                return (CGRectEdge)(preferredEdge == CGRectMaxYEdge ? CGRectMaxXEdge : CGRectMaxYEdge);
            }
            
            return currentEdge;
        };
		
		CGRect (^fitRectToScreen)(CGRect) = ^ (CGRect proposedRect) {
			NSRect screenRect = positioningView.window.screen.visibleFrame;
			
			if (proposedRect.origin.y < NSMinY(screenRect))
				proposedRect.origin.y = NSMinY(screenRect);
			if (proposedRect.origin.x < NSMinX(screenRect))
				proposedRect.origin.x = NSMinX(screenRect);
			
			if (NSMaxY(proposedRect) > NSMaxY(screenRect))
				proposedRect.origin.y = (NSMaxY(screenRect) - NSHeight(proposedRect));
			if (NSMaxX(proposedRect) > NSMaxX(screenRect))
				proposedRect.origin.x = (NSMaxX(screenRect) - NSWidth(proposedRect));
			
			return proposedRect;
		};
        
        NSUInteger attemptCount = 0;
        while (!checkPopoverSizeForScreenWithPopoverEdge(popoverEdge)) {
            if (attemptCount > 4) {
				popoverEdge = preferredEdge;
				return fitRectToScreen(popoverRectForEdge(popoverEdge));
				break;
			}
            
            popoverEdge = nextEdgeForEdge(popoverEdge);
            attemptCount ++;
        }
		
        return (CGRect)popoverRectForEdge(popoverEdge);
    };
    
    CGRect popoverScreenRect = popoverRect();
    RBLPopoverBackgroundView *backgroundView = [self.backgroundViewClass backgroundViewForContentSize:contentViewSize popoverEdge:popoverEdge originScreenRect:screenPositioningRect];
    
    CGRect contentViewFrame = [self.backgroundViewClass contentViewFrameForBackgroundFrame:backgroundView.bounds popoverEdge:popoverEdge];
    self.contentViewController.view.frame = contentViewFrame;
    [backgroundView addSubview:self.contentViewController.view];
	self.popoverWindow = [[NSWindow alloc] initWithContentRect:popoverScreenRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [self.popoverWindow setReleasedWhenClosed:NO];
    RBLPopoverWindowContentView *contentView = [[RBLPopoverWindowContentView alloc] initWithFrame:backgroundView.bounds];
	contentView.arrowEdge = [backgroundView arrowEdgeForPopoverEdge:popoverEdge];
    [contentView addSubview:backgroundView];
    [self.popoverWindow setOpaque:NO];
    [self.popoverWindow setBackgroundColor:[NSColor clearColor]];
    self.popoverWindow.contentView = contentView;
    self.popoverWindow.alphaValue = 0.0;
    [positioningView.window addChildWindow:self.popoverWindow ordered:NSWindowAbove];
	[self.popoverWindow makeKeyAndOrderFront:self];
	[backgroundView updateMaskLayer];
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
    fadeInAnimation.duration = 0.3;
    fadeInAnimation.rbl_completionBlock = ^ {
        self.animating = NO;
        //[self.contentViewController viewDidAppear:YES];
        
        if (self.didShowBlock)
            self.didShowBlock(self);
    };
    
    self.popoverWindow.animations = [NSDictionary dictionaryWithObject:fadeInAnimation forKey:@"alphaValue"];
    self.animating = YES;
    [self.popoverWindow.animator setAlphaValue:1.0];
}

#pragma mark -
#pragma mark Closing

- (void)close
{
    [self closeWithFadeoutDuration:RBLPopoverDefaultFadeoutDuration];
}

- (void)closeWithFadeoutDuration:(NSTimeInterval)duration
{
    if (self.animating)
        return;
    
    if (self.transientEventMonitor != nil) {
		[self removeEventMonitor];
	}
    
    if (self.willCloseBlock != nil)
        self.willCloseBlock(self);
    
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
    fadeOutAnimation.duration = duration;
    fadeOutAnimation.rbl_completionBlock = ^ {
        [self.popoverWindow.parentWindow removeChildWindow:self.popoverWindow];
        [self.popoverWindow close];
        self.popoverWindow.contentView = nil;
        self.animating = NO;
        
        if (self.didCloseBlock != nil)
            self.didCloseBlock(self);
        
        self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, self.contentViewController.view.frame.origin.y, self.originalViewSize.width, self.originalViewSize.height);
    };
    
    self.popoverWindow.animations = [NSDictionary dictionaryWithObject:fadeOutAnimation forKey:@"alphaValue"];
    self.animating = YES;
    [self.popoverWindow.animator setAlphaValue:0.0];
}

- (IBAction)performClose:(id)sender
{
    [self close];
}

#pragma mark -
#pragma mark Event Monitor

- (void)removeEventMonitor
{
	[NSEvent removeMonitor:self.transientEventMonitor];
	self.transientEventMonitor = nil;
}

@end

//***************************************************************************

CGFloat const RBLPopoverBackgroundViewBorderRadius = 5.0;
CGFloat const RBLPopoverBackgroundViewArrowHeight = 17.0;
CGFloat const RBLPopoverBackgroundViewArrowWidth = 35.0;

//***************************************************************************

@implementation RBLPopoverBackgroundView

+ (CGSize)sizeForBackgroundViewWithContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge
{
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

+ (CGRect)contentViewFrameForBackgroundFrame:(CGRect)backgroundFrame popoverEdge:(CGRectEdge)popoverEdge
{
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
            break;
    }
    
    return returnFrame;
}

+ (RBLPopoverBackgroundView *)backgroundViewForContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect
{
    CGSize size = [self sizeForBackgroundViewWithContentSize:contentSize popoverEdge:popoverEdge];
    RBLPopoverBackgroundView *returnView = [[self.class alloc] initWithFrame:NSMakeRect(0.0, 0.0, size.width, size.height) popoverEdge:popoverEdge originScreenRect:originScreenRect];
    return returnView;
}

- (CGPathRef)newPopoverPathForEdge:(CGRectEdge)popoverEdge inFrame:(CGRect)frame
{
	CGRectEdge arrowEdge = [self arrowEdgeForPopoverEdge:popoverEdge];
	
	CGRect contentRect = CGRectIntegral([[self class] contentViewFrameForBackgroundFrame:frame popoverEdge:self.popoverEdge]);
	CGFloat minX = NSMinX(contentRect);
	CGFloat maxX = NSMaxX(contentRect);
	CGFloat minY = NSMinY(contentRect);
	CGFloat maxY = NSMaxY(contentRect);
	
	CGRect windowRect = self.screenOriginRect;
	windowRect.origin = [self.window convertScreenToBase:self.screenOriginRect.origin];
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

- (id)initWithFrame:(CGRect)frame popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect //originScreenRect is in the screen coordinate space
{
	self = [super initWithFrame:frame];
	if (self == nil)
		return nil;
    
	_popoverEdge = popoverEdge;
	_screenOriginRect = originScreenRect;
	_strokeColor = [NSColor blackColor];
	_fillColor = [NSColor whiteColor];
	
	return self;
}

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
	CGPathRef outerBorder = [self newPopoverPathForEdge:self.popoverEdge inFrame:self.bounds];
	CGContextSetStrokeColorWithColor(context, self.strokeColor.rbl_CGColor);
	CGContextAddPath(context, outerBorder);
	CGContextStrokePath(context);
	
	CGContextSetFillColorWithColor(context, self.fillColor.rbl_CGColor);
	CGContextAddPath(context, outerBorder);
	CGContextFillPath(context);
	
	CGPathRelease(outerBorder);
}

- (void)updateMaskLayer
{
	CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGPathRef path = [self newPopoverPathForEdge:self.popoverEdge inFrame:self.bounds];
    maskLayer.path = path;
    maskLayer.fillColor = CGColorGetConstantColor(kCGColorBlack);
    
    CGPathRelease(path);
    
    self.layer.mask = maskLayer;
	
}

- (CGRectEdge)arrowEdgeForPopoverEdge:(CGRectEdge)popoverEdge
{
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

@end

// Hmm I'm not sure I like how this takes some of the drawing responsibility away from the background view breaking the extensibility.
// But it works.

@implementation RBLPopoverWindowContentView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self == nil) return nil;
    
	_arrowEdge = CGRectMinYEdge;
	self.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
    
    return self;
}

- (BOOL)isOpaque {
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];
	
	CGRect targetRect = CGRectZero;
	switch (self.arrowEdge) {
		case CGRectMinYEdge:
			targetRect = CGRectMake(1.0f, 1.0f + RBLPopoverBackgroundViewArrowHeight, CGRectGetWidth(self.bounds) - 2.0f, CGRectGetHeight(self.bounds) - RBLPopoverBackgroundViewArrowHeight - 2.0f);
			break;
		case CGRectMaxXEdge:
			targetRect = CGRectMake(1.0f, 1.0f, CGRectGetWidth(self.bounds) - 2.0f - RBLPopoverBackgroundViewArrowHeight, CGRectGetHeight(self.bounds) - 2.0f);
			break;
		case CGRectMaxYEdge:
			targetRect = CGRectMake(1.0f, 1.0f, CGRectGetWidth(self.bounds) - 2.0f, CGRectGetHeight(self.bounds) - 2.0f - RBLPopoverBackgroundViewArrowHeight);
			break;
		case CGRectMinXEdge:
			targetRect = CGRectMake(RBLPopoverBackgroundViewArrowHeight + 1.0f, 1.0f, CGRectGetWidth(self.bounds) - 2.0f - RBLPopoverBackgroundViewArrowHeight, CGRectGetHeight(self.bounds) - 2.0f);
			break;
			
		default:
			break;
	}
	
	NSBezierPath *roundRectPath = [NSBezierPath bezierPathWithRoundedRect:targetRect xRadius:RBLPopoverBackgroundViewBorderRadius yRadius:RBLPopoverBackgroundViewBorderRadius];
	[[NSColor whiteColor] set];
	[roundRectPath fill];
    
    [NSGraphicsContext restoreGraphicsState];
}

@end

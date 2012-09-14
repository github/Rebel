//
//  RBLPopover.h
//  Rebel
//
//  Created by Danny Greg on 13/09/2012.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RBLView.h"

@class RBLPopover;

typedef enum : NSUInteger {
	RBLPopoverViewControllerBehaviorApplicationDefined = 0,
    RBLPopoverViewControllerBehaviorTransient = 1,
    RBLPopoverViewControllerBehaviorSemiTransient = 2 //Currently not supported, here for forwards compatibility purposes
} RBLPopoverViewControllerBehavior;

typedef void (^RBLPopoverDelegateBlock)(RBLPopover *popover);

@interface RBLPopover : NSResponder

@property (nonatomic, strong) NSViewController *contentViewController;
@property (nonatomic, strong) Class backgroundViewClass; //Must be a subclass of RBLPopoverBackgroundView
@property (nonatomic) CGSize contentSize; //CGSizeZero uses the size of the view on contentViewController
@property (nonatomic) BOOL animates;
@property (nonatomic) RBLPopoverViewControllerBehavior behavior;
@property (nonatomic, readonly) BOOL shown;
@property (nonatomic, readonly) CGRect positioningRect;

//Block callbacks
@property (nonatomic, copy) RBLPopoverDelegateBlock willCloseBlock;
@property (nonatomic, copy) RBLPopoverDelegateBlock didCloseBlock;

@property (nonatomic, copy) RBLPopoverDelegateBlock willShowBlock;
@property (nonatomic, copy) RBLPopoverDelegateBlock didShowBlock;

- (id)initWithContentViewController:(NSViewController *)viewController;

- (void)showRelativeToRect:(CGRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(CGRectEdge)preferredEdge;

- (void)close;
- (void)closeWithFadeoutDuration:(NSTimeInterval)duration;
- (IBAction)performClose:(id)sender;

@end

@interface RBLPopoverBackgroundView : RBLView

+ (CGSize)sizeForBackgroundViewWithContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge;
+ (CGRect)contentViewFrameForBackgroundFrame:(CGRect)frame popoverEdge:(CGRectEdge)popoverEdge;
+ (RBLPopoverBackgroundView *)backgroundViewForContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect;

- (id)initWithFrame:(CGRect)frame popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect;
- (CGPathRef)newPopoverPathForEdge:(CGRectEdge)popoverEdge inFrame:(CGRect)frame; //override in subclasses to change the shape of the popover, but still use the default drawing.

//Used in the default implementation
@property (nonatomic, strong) NSColor *strokeColor;
@property (nonatomic, strong) NSColor *fillColor;

@end

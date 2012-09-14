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
@property (nonatomic, readonly, getter = isShown) BOOL shown;
@property (nonatomic, readonly) CGRect positioningRect;

//Block callbacks
@property (nonatomic, copy) RBLPopoverDelegateBlock willCloseBlock;
@property (nonatomic, copy) RBLPopoverDelegateBlock didCloseBlock;

@property (nonatomic, copy) RBLPopoverDelegateBlock willShowBlock;
@property (nonatomic, copy) RBLPopoverDelegateBlock didShowBlock;

// Designated initialiser.
- (instancetype)initWithContentViewController:(NSViewController *)viewController;

// Displays the popover
//
// positioningRect - The area which the popover should "cling" to. Given in
//                   positioningView's coordinate space.
// positioningView - The view which the positioningRect is relative to.
// preferredEdge   - The edge of positioningRect which the popover should
//                   "cling" to. If the entire popover will not fit on the
//                   screen when clinging to the
//                   preferredEdge another edge will be used to ensure the
//                   content is visible. In the event that no edge allows the
//                   popover to fit on the screen, preferredEdge is used.
- (void)showRelativeToRect:(CGRect)positioningRect ofView:(NSView *)positioningView preferredEdge:(CGRectEdge)preferredEdge;

// Closes the popover with the default fadeout duration (if the popover
// animates).
- (void)close;

// Closes the popover with the given duration. If animates is set to NO the
// popover closes immediately.
//
// duration - the duration of the fade animation.
- (void)closeWithFadeoutDuration:(NSTimeInterval)duration;

// Convenience method exposed for nib files.
- (IBAction)performClose:(id)sender;

@end

@interface RBLPopoverBackgroundView : RBLView

+ (CGSize)sizeForBackgroundViewWithContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge;
+ (CGRect)contentViewFrameForBackgroundFrame:(CGRect)frame popoverEdge:(CGRectEdge)popoverEdge;
+ (instancetype)backgroundViewForContentSize:(CGSize)contentSize popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect;

- (instancetype)initWithFrame:(CGRect)frame popoverEdge:(CGRectEdge)popoverEdge originScreenRect:(CGRect)originScreenRect;
- (CGPathRef)newPopoverPathForEdge:(CGRectEdge)popoverEdge inFrame:(CGRect)frame; //override in subclasses to change the shape of the popover, but still use the default drawing.

//Used in the default implementation
@property (nonatomic, strong) NSColor *strokeColor;
@property (nonatomic, strong) NSColor *fillColor;

@end

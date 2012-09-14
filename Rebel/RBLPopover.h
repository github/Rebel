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

// Defines the different types of behavior of an `RBLPopover`
//
// RBLPopoverViewControllerBehaviorApplicationDefined - The application decides
//                                                      when the popover should
//                                                      open and close, by doing
//                                                      so manually.
// RBLPopoverViewControllerBehaviorTransient          - If there is a mouse
//                                                      click anywhere other
//                                                      than in the popover the
//                                                      popover is closed.
// RBLPopoverViewControllerBehaviorSemiTransient      - Unsupported, here for
//                                                      forwards compatibility.
typedef enum : NSUInteger {
	RBLPopoverViewControllerBehaviorApplicationDefined = 0,
    RBLPopoverViewControllerBehaviorTransient = 1,
    RBLPopoverViewControllerBehaviorSemiTransient = 2 //Currently not supported, here for forwards compatibility purposes
} RBLPopoverViewControllerBehavior;

typedef void (^RBLPopoverDelegateBlock)(RBLPopover *popover);

@interface RBLPopover : NSResponder

// The view controller providing the view displayed within the popover.
@property (nonatomic, strong) NSViewController *contentViewController;

// The class of which an instance is created which sits behind the
// `contentViewController`'s view. This is useful for customising the appearance
// of the popover.
// Note that this must be a subclass of `RBLPopoverBackgroundView`.
@property (nonatomic, strong) Class backgroundViewClass;

// The size that, when displayed, the popover's content should be.
// Passing `CGSizeZero` uses the size of the `contentViewController`'s view.
@property (nonatomic) CGSize contentSize;

// Whether the next open/close of the popover should be animated.
// Note that this property is checked just before the animation is performed.
// Therefore it is possible to animate the showing of the popover but hide the
// closing and vice versa.
@property (nonatomic) BOOL animates;

// How the popover should respond to user events, in regard to automatically
// closing the popover.
// See the definition of `RBLPopoverViewControllerBehavior` for more
// information.
@property (nonatomic) RBLPopoverViewControllerBehavior behavior;

// Whether the popover is currently visible.
@property (nonatomic, readonly, getter = isShown) BOOL shown;

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

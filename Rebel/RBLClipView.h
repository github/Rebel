//
//  RBLClipView.h
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-09-14.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

//
// A faster NSClipView based on CAScrollLayer.
//
@interface RBLClipView : NSClipView

// The backing layer for this view.
@property (nonatomic, strong) CAScrollLayer *layer;

// Whether the content in this view is opaque.
//
// Defaults to NO.
@property (nonatomic, getter = isOpaque) BOOL opaque;

@end

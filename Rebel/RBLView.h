//
//  RBLView.h
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 * A base class for saner and more full-featured layer-backed views.
 */
@interface RBLView : NSView

/*
 * The backing layer's background color, or nil if none has been set.
 */
@property (nonatomic, strong) NSColor *backgroundColor;

@end

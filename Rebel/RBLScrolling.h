//
//  RBLScrolling.h
//  Rebel
//
//  Created by Rob Rix on 27/05/2014.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/// Scrolls `view`’s `enclosingScrollView` just enough to reveal `rect`,
/// rather than scrolling it such that it lies in the middle of the new
/// `visibleRect`. This resolves issues where scrolling quickly through
/// long lists, e.g. by holding down the down arrow key in a table or
/// outline view, will otherwise jump wildly around the scrollable
/// region.
BOOL RBLScrollRectInViewToVisible(NSView *view, NSRect rect);

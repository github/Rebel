//
//  RBLOutlineView.h
//  Rebel
//
//  Created by Rob Rix on 26/05/2014.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/// A standard outline view with one fix.
///
/// As opposed to trying to scroll rects into the middle of the view each time,
/// we move them just enough as to make them visible. This fixes the outline
/// view appearing to have some kind of seizure when you, for example, hold
/// down an arrow key to scroll through its cells really fast.
///
/// This fix applies to both cell and view based outline views. This is the
/// same fix as implemented in `RBLTableView`.
@interface RBLOutlineView : NSOutlineView

@end

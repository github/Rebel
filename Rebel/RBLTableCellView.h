//
//  RBLTableCellView.h
//  Rebel
//
//  Created by Jonathan Willing on 10/23/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// A subclass of NSTableCellView that adds a method
// which notifies when the cell view will be reused.
// Useful to clear properties and bindings before reuse.
@interface RBLTableCellView : NSTableCellView

// Called immediately before the cell view is going to be added
// to a new table row view. At the time this is called, the cell
// view will not have a superview.
- (void)prepareForReuse;

@end

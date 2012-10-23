//
//  RBLTableCellView.h
//  Rebel
//
//  Created by Jonathan Willing on 10/23/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RBLTableCellView : NSTableCellView

// Cell will be added as a subview to a new table row view.
- (void)cellViewWillReuse;

// Cell has been added to a new table row view
- (void)cellViewDidReuse;

@end

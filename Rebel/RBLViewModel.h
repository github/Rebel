//
//  RBLViewModel.h
//  Rebel
//
//  Created by Josh Abernathy on 9/11/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBLViewModel : NSObject

// The model which the view model represents.
@property (nonatomic, readonly, strong) id model;

// The parent view model. Can be nil.
@property (nonatomic, readonly, weak) RBLViewModel *parentViewModel;

// Traverses up the `parentViewModel` chain until it finds a view model with a
// nil parent.
@property (nonatomic, readonly, weak) RBLViewModel *rootViewModel;

// Calls -initWithModel:parentViewModel: with a nil model and parent view model.
- (id)init;

// Creates a new view model with the given model and parent view model. Both
// arguments may be nil.
- (id)initWithModel:(id)model parentViewModel:(RBLViewModel *)parentViewModel;

// Present the given error. The default implementation calls `-presentError:` on
// its `parentViewModel`. Subclasses can use this to actually present the error
// or modify the error before passing it up the parent chain. Returns whether
// anyone handled the error.
- (BOOL)presentError:(NSError *)error;

// If the receiver responds to `action`, the message is sent with the given
// argument. If it doesn't, it calls `-tryToPerform:with:` on the
// `parentViewModel`. Returns YES if someone handled the action, NO if not.
- (BOOL)tryToPerform:(SEL)action with:(id)object;

@end

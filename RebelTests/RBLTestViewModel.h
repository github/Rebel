//
//  RBLTestViewModel.h
//  Rebel
//
//  Created by Josh Abernathy on 9/12/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Rebel/Rebel.h>

@interface RBLTestViewModel : RBLViewModel

// Has the object been sent `-presentError:`?
@property (nonatomic, readonly, assign) BOOL gotPresentError;

// The argument passed in to `-someOtherThing:`.
@property (nonatomic, readonly, strong) id argumentReceived;

// Do some thing with the argument. Sets the `argumentReceived` property to `wat`.
- (void)someOtherThing:(id)wat;

@end

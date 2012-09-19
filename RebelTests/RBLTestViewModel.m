//
//  RBLTestViewModel.m
//  Rebel
//
//  Created by Josh Abernathy on 9/12/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLTestViewModel.h"

@interface RBLTestViewModel ()
@property (nonatomic, readwrite, assign) BOOL gotPresentError;
@property (nonatomic, readwrite, strong) id argumentReceived;
@end

@implementation RBLTestViewModel

#pragma mark RBLViewModel

- (id)initWithModel:(id)model parentViewModel:(RBLViewModel *)parentViewModel {
	self = [super initWithModel:model parentViewModel:parentViewModel];
	if (self == nil) return nil;

	_calledInitWithModelParentViewModel = YES;

	return self;
}

- (BOOL)presentError:(NSError *)error {
	self.gotPresentError = YES;
	return [super presentError:error];
}

#pragma mark API

- (void)someOtherThing:(id)wat {
	self.argumentReceived = wat;
}

@end

//
//  RBLViewModel.m
//  Rebel
//
//  Created by Josh Abernathy on 9/11/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLViewModel.h"

@implementation RBLViewModel

#pragma mark API

- (id)initWithModel:(id)model parentViewModel:(RBLViewModel *)parentViewModel {
	self = [super init];
	if (self == nil) return nil;

	_model = model;
	_parentViewModel = parentViewModel;

	return self;
}

- (RBLViewModel *)rootViewModel {
	if (self.parentViewModel == nil) return self;
	return self.parentViewModel.rootViewModel;
}

- (BOOL)presentError:(NSError *)error {
	return [self.parentViewModel presentError:error];
}

- (BOOL)tryToPerform:(SEL)action with:(id)object {
	if ([self respondsToSelector:action]) {
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:action]];
		invocation.selector = action;
		[invocation setArgument:&object atIndex:2];
		[invocation invokeWithTarget:self];
		return YES;
	} else {
		return [self.parentViewModel tryToPerform:action with:object];
	}
}

@end

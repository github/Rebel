//
//  RBLViewModel.m
//  Rebel
//
//  Created by Josh Abernathy on 9/11/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLViewModel.h"
#import <objc/message.h>

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
		objc_msgSend(self, action, object, nil);
		return YES;
	} else {
		return [self.parentViewModel tryToPerform:action with:object];
	}
}

@end

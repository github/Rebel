//
//  CAAnimation+RBLBlockAdditions.m
//  Rebel
//
//  Created by Danny Greg on 13/09/2012.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "CAAnimation+RBLBlockAdditions.h"

#import <objc/runtime.h>

static void *RBLCAAnimationCompletionBlockAssociatedObjectKey = &RBLCAAnimationCompletionBlockAssociatedObjectKey;

@interface RBLCAAnimationDelegate : NSObject

@property (nonatomic, weak) CAAnimation *animation;

@end

@implementation CAAnimation (RBLBlockAdditions)

- (void)setRbl_completionBlock:(void (^)(BOOL))block {
	RBLCAAnimationDelegate *delegateStub = [[RBLCAAnimationDelegate alloc] init];
	self.delegate = delegateStub;
	objc_setAssociatedObject(self, RBLCAAnimationCompletionBlockAssociatedObjectKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(BOOL))rbl_completionBlock {
	return objc_getAssociatedObject(self, RBLCAAnimationCompletionBlockAssociatedObjectKey);
}

@end

@implementation RBLCAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if (self.animation.rbl_completionBlock != nil) self.animation.rbl_completionBlock(flag);
}

@end

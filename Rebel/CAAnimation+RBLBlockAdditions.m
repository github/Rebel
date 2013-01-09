//
//  CAAnimation+RBLBlockAdditions.m
//  Rebel
//
//  Created by Danny Greg on 13/09/2012.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "CAAnimation+RBLBlockAdditions.h"

@interface RBLCAAnimationDelegate : NSObject
@property (nonatomic, copy) void (^completion)(BOOL finished);
@end

@implementation CAAnimation (RBLBlockAdditions)

- (void)setRbl_completionBlock:(void (^)(BOOL))rbl_completionBlock {
	RBLCAAnimationDelegate *stub = [RBLCAAnimationDelegate new];
	stub.completion = rbl_completionBlock;
	self.delegate = stub;
}

- (void (^)(BOOL))rbl_completionBlock {
	return [(RBLCAAnimationDelegate *)self.delegate completion];
}

@end

@implementation RBLCAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
	if (self.completion != nil)
		self.completion(flag);
}

@end

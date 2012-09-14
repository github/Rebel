//
//  NSColor+RBLCGColorAdditionsSpec.m
//  Rebel
//
//  Created by Danny Greg on 2012-09-13.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

SpecBegin(CAAnimationRBLBlockAdditions)

__block CAAnimation *animation = nil;
__block BOOL completionExecuted = NO;
__block void(^completionBlock)() = ^ {
	completionExecuted = YES;
};

before(^{
	animation = [[CAAnimation alloc] init];
	animation.rbl_completionBlock = completionBlock;
	
	expect(animation).toNot.beNil();
});

it(@"Should have set a completion block", ^ {
	expect(animation.rbl_completionBlock).toNot.beNil();
	expect(animation.rbl_completionBlock).to.equal(completionBlock);
	if (animation.rbl_completionBlock != nil) animation.rbl_completionBlock();
	expect(completionExecuted).to.beTruthy();
});

it(@"Should have set itself has a delegate", ^{
	expect(animation.delegate).to.equal(animation);
});

SpecEnd

//
//  NSColor+RBLCGColorAdditionsSpec.m
//  Rebel
//
//  Created by Danny Greg on 2012-09-13.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

SpecBegin(CAAnimationRBLBlockAdditions);

__block CAAnimation *animation = nil;

before(^{
	animation = [[CAAnimation alloc] init];
	animation.rbl_completionBlock = ^ {
		NSLog(@"Hello World!");
	};
	
	expect(animation).toNot.beNil();
});

it(@"Should have set a completion block", ^ {
	expect(animation.rbl_completionBlock).toNot.beNil();
});

it(@"Should have set itself has a delegate", ^{
	expect(animation.delegate == animation).to.beTruthy();
});

SpecEnd

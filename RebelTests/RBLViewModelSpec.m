//
//  RBLViewModelSpec.m
//  Rebel
//
//  Created by Josh Abernathy on 9/11/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

@interface RBLTestViewModel : RBLViewModel
@property (nonatomic, assign) BOOL gotPresentError;
@end

@implementation RBLTestViewModel

- (void)someOtherThing:(id)wat {
	
}

- (BOOL)presentError:(NSError *)error {
	self.gotPresentError = YES;
	return [super presentError:error];
}

@end

SpecBegin(RBLViewModel)

RBLTestViewModel *rootViewModel = [[RBLTestViewModel alloc] initWithModel:@"root" parentViewModel:nil];
RBLTestViewModel *parentViewModel = [[RBLTestViewModel alloc] initWithModel:@"parent" parentViewModel:rootViewModel];
RBLTestViewModel *childViewModel = [[RBLTestViewModel alloc] initWithModel:@"child" parentViewModel:parentViewModel];

describe(@"the view model chain", ^{
	it(@"should know its parent view model", ^{
		expect(childViewModel.parentViewModel).to.equal(parentViewModel);
		expect(parentViewModel.parentViewModel).to.equal(rootViewModel);
		expect(rootViewModel.parentViewModel).to.beNil();
	});

	it(@"should know its root view model", ^{
		expect(childViewModel.rootViewModel).to.equal(rootViewModel);
		expect(parentViewModel.rootViewModel).to.equal(rootViewModel);
		expect(rootViewModel.rootViewModel).to.equal(rootViewModel);
	});
});

describe(@"tryToPerform:with:", ^{
	it(@"should return NO if no one responds to the action", ^{
		BOOL result = [childViewModel tryToPerform:@selector(doSomeStuff:) with:@42];
		expect(result).to.beFalsy();
	});

	it(@"should return YES if someone responds to the action", ^{
		BOOL result = [childViewModel tryToPerform:@selector(presentError:) with:nil];
		expect(result).to.beTruthy();

		result = [childViewModel tryToPerform:@selector(someOtherThing:) with:@42];
		expect(result).to.beTruthy();
	});
});

describe(@"-presentError", ^{
	it(@"should return NO when no one handled it", ^{
		BOOL presented = [childViewModel presentError:nil];
		expect(presented).to.beFalsy();
	});

	it(@"should travel up the parent view model chain", ^{
		childViewModel.gotPresentError = NO;
		parentViewModel.gotPresentError = NO;
		rootViewModel.gotPresentError = NO;

		[childViewModel presentError:nil];

		expect(childViewModel.gotPresentError).to.beTruthy();
		expect(parentViewModel.gotPresentError).to.beTruthy();
		expect(rootViewModel.gotPresentError).to.beTruthy();
	});
});

SpecEnd

//
//  RBLViewModelSpec.m
//  Rebel
//
//  Created by Josh Abernathy on 9/11/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLTestViewModel.h"

SpecBegin(RBLViewModel)

__block RBLTestViewModel *rootViewModel;
__block RBLTestViewModel *parentViewModel;
__block RBLTestViewModel *childViewModel;

beforeEach(^{
	rootViewModel = [[RBLTestViewModel alloc] initWithModel:@"root" parentViewModel:nil];
	parentViewModel = [[RBLTestViewModel alloc] initWithModel:@"parent" parentViewModel:rootViewModel];
	childViewModel = [[RBLTestViewModel alloc] initWithModel:@"child" parentViewModel:parentViewModel];
});

describe(@"-init", ^{
	it(@"should call -initWithModel:parentViewModel:", ^{
		RBLTestViewModel *viewModel = [[RBLTestViewModel alloc] init];
		expect(viewModel.calledInitWithModelParentViewModel).to.beTruthy();
	});
});

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

		id arg = @42;
		result = [childViewModel tryToPerform:@selector(someOtherThing:) with:arg];
		expect(result).to.beTruthy();
		expect(childViewModel.argumentReceived).to.equal(arg);
		expect(parentViewModel.argumentReceived).to.beNil();
		expect(rootViewModel.argumentReceived).to.beNil();
	});
});

describe(@"-presentError:", ^{
	it(@"should return NO when no one handled it", ^{
		BOOL presented = [childViewModel presentError:nil];
		expect(presented).to.beFalsy();
	});

	it(@"should travel up the parent view model chain", ^{
		[childViewModel presentError:nil];

		expect(childViewModel.gotPresentError).to.beTruthy();
		expect(parentViewModel.gotPresentError).to.beTruthy();
		expect(rootViewModel.gotPresentError).to.beTruthy();
	});
});

SpecEnd

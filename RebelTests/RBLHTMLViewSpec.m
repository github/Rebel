//
//  RBLHTMLViewSpec.m
//  Rebel
//
//  Created by Josh Abernathy on 3/14/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <Quick/Quick.h>
#import <Rebel/Rebel.h>

QuickSpecBegin(RBLHTMLViewSpec)

static NSString * const HTML = @"<span>hey brother</span>";

__block RBLHTMLView *view;

beforeEach(^{
	view = [[RBLHTMLView alloc] initWithFrame:NSZeroRect];
	view.HTML = HTML;
});

it(@"should contain the set HTML", ^{
	expect([view.mainFrame.DOMDocument.body.innerHTML rangeOfString:HTML].length).to.beGreaterThan(0);
});

it(@"shouldn't be loading after setting the HTML", ^{
	expect(view.isLoading).to.beFalsy();
});

it(@"shouldn't be loading after setting the CSS", ^{
	view.CSS = @"body { color: red; }";
	expect(view.isLoading).to.beFalsy();
});

QuickSpecEnd

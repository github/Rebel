//
//  RBLHTMLViewSpec.m
//  Rebel
//
//  Created by Josh Abernathy on 3/14/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

SpecBegin(RBLHTMLView)

static NSString * const HTML = @"<span>hey brother</span>";

__block RBLHTMLView *view;

beforeEach(^{
	view = [[RBLHTMLView alloc] initWithFrame:NSZeroRect];
	view.HTML = HTML;
});

it(@"should contain the set HTML", ^{
	expect([view.mainFrame.DOMDocument.body.innerHTML rangeOfString:HTML].length > 0).to.beTruthy();
});

it(@"shouldn't be loading after setting the HTML", ^{
	expect(view.isLoading).to.beFalsy();
});

it(@"shouldn't be loading after setting the CSS", ^{
	view.CSS = @"body { color: red; }";
	expect(view.isLoading).to.beFalsy();
});

SpecEnd

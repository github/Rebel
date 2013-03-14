//
//  RBLHTMLViewSpec.m
//  Rebel
//
//  Created by Josh Abernathy on 3/14/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

SpecBegin(RBLHTMLView)

it(@"should contain the set HTML", ^{
	static NSString * const HTML = @"<span>hey buddy</span>";
	RBLHTMLView *view = [[RBLHTMLView alloc] initWithFrame:NSZeroRect];
	view.HTML = HTML;
	expect([view.mainFrame.DOMDocument.body.innerHTML rangeOfString:HTML].length > 0).to.beTruthy();
});

SpecEnd

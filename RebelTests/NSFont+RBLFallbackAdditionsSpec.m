//
//  NSFont+RBLFallbackAdditionsSpec.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-12-09.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

SpecBegin(NSFontRBLFallbackAdditions)

describe(@"+rbl_fontWithName:size:fallbackNames:", ^{
	__block NSFont *font;

	afterEach(^{
		// All of the below tests should return Helvetica size 12.
		expect(font).notTo.beNil();
		expect(font.familyName).to.equal(@"Helvetica");
		expect(font.pointSize).to.equal(12);
	});

	it(@"should return a valid font without any fallback names", ^{
		font = [NSFont rbl_fontWithName:@"Helvetica" size:12 fallbackNames:@[]];
	});

	it(@"should return a valid font with fallback names", ^{
		font = [NSFont rbl_fontWithName:@"Helvetica" size:12 fallbackNames:@[ @"Lucida Grande" ]];
	});

	it(@"should return a fallback font if the desired font couldn't be found", ^{
		font = [NSFont rbl_fontWithName:@"somemadeupfontname" size:12 fallbackNames:@[ @"Helvetica" ]];
	});

	it(@"should return the second fallback font if the first two desired fonts couldn't be found", ^{
		font = [NSFont rbl_fontWithName:@"somemadeupfontname" size:12 fallbackNames:@[ @"anothermadeupfontname", @"Helvetica" ]];
	});

	it(@"should search the fallback font list in order", ^{
		font = [NSFont rbl_fontWithName:@"somemadeupfontname" size:12 fallbackNames:@[ @"Helvetica", @"Lucida Grande" ]];
	});
});

SpecEnd

//
//  NSColor+RBLAdditionsTests.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-29.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

SpecBegin(NSColorRBLAdditions)
	
	describe(@"CGColor from NSColor", ^{
		__block NSColor *nsColor;

		before(^{
			nsColor = nil;
		});

		after(^{
			expect(nsColor).notTo.beNil();

			// The result of our method should match that of the 10.8 API.
			CGColorRef rblColor = nsColor.rbl_CGColor;
			expect(rblColor).notTo.beNil();

			CGColorRef cgColor = nsColor.CGColor;
			expect(cgColor).notTo.beNil();

			expect(CGColorEqualToColor(rblColor, cgColor)).to.beTruthy();
		});

		it(@"should return a CGColor for an predefined NSColor", ^{
			nsColor = [NSColor redColor];
		});

		it(@"should return a CGColor for an RGB NSColor", ^{
			nsColor = [NSColor colorWithCalibratedRed:0.75 green:0.5 blue:0.25 alpha:0.1];
		});
	});

	describe(@"NSColor from CGColor", ^{
		__block CGColorRef cgColor;

		before(^{
			cgColor = NULL;
		});

		after(^{
			expect(cgColor).notTo.beNil();

			// The result of our method should match that of the 10.8 API.
			NSColor *rblColor = [NSColor rbl_colorWithCGColor:cgColor];
			NSColor *nsColor = [NSColor colorWithCGColor:cgColor];
			expect(rblColor).to.equal(nsColor);
		});

		it(@"should return an NSColor for a constant CGColor", ^{
			cgColor = CGColorGetConstantColor(kCGColorWhite);
		});

		it(@"should return an NSColor for an RGB CGColor", ^{
			cgColor = CGColorCreateGenericRGB(0.75, 0.5, 0.25, 0.1);
		});

		it(@"should return an NSColor for a gray CGColor", ^{
			cgColor = CGColorCreateGenericGray(0.5, 0.75);
		});
	});

	it(@"should return a pattern CGColor", ^{
		NSURL *imageURL = [[NSBundle bundleForClass:self.class] URLForResource:@"testimage" withExtension:@"jpg"];
		expect(imageURL).notTo.beNil();

		NSImage *image = [[NSImage alloc] initByReferencingURL:imageURL];
		expect(image).notTo.beNil();

		NSColor *patternNSColor = [NSColor colorWithPatternImage:image];
		expect(patternNSColor).notTo.beNil();
		
		CGColorRef patternCGColor = patternNSColor.rbl_CGColor;
		expect(patternCGColor).notTo.beNil();
		expect(CGColorGetPattern(patternCGColor)).notTo.beNil();
	});

SpecEnd

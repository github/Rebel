//
//  RBLResizableImageSpec.m
//  Rebel
//
//  Created by Alan Rogers on 16/04/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RBLResizableImage.h"

SpecBegin(RBLResizableImage)

__block RBLResizableImage *testImage = nil;
__block void(^expectBlueBorder)(NSBitmapImageRep* imageRep, NSSize size) = nil;

beforeEach(^{
	NSURL *testImageURL = [[NSBundle bundleForClass:self.class] URLForResource:@"<RBLResizableImageSpec>_testimage" withExtension:@"tiff"];
	
	expect(testImageURL).toNot.beNil();
	
	testImage = [[RBLResizableImage alloc] initByReferencingURL:testImageURL];

	expect(testImage).toNot.beNil();
	
	expectBlueBorder = ^(NSBitmapImageRep *imageRep, NSSize size) {
		NSUInteger topLeft[4], bottomRight[4];
		
		// confirm we have the borders
		[imageRep getPixel:&topLeft[0] atX:0 y:0];
		
		NSUInteger red = topLeft[0];
		NSUInteger green = topLeft[1];
		NSUInteger blue = topLeft[2];
		NSUInteger alpha = topLeft[3];
		
		expect(red).to.equal(0);
		expect(green).to.equal(0);
		expect(blue).to.equal(255);
		expect(alpha).to.equal(255);

		[imageRep getPixel:&bottomRight[0] atX:(NSUInteger)(size.width - 1) y:(NSUInteger)(size.height - 1)];

		red = bottomRight[0];
		green = bottomRight[1];
		blue = bottomRight[2];
		alpha = bottomRight[3];
		
		expect(red).to.equal(0);
		expect(green).to.equal(0);
		expect(blue).to.equal(255);
		expect(alpha).to.equal(255);
	};
});

it(@"should use @1x asset in @1x context", ^{
	CGSize targetSize = { .width = 50, .height = 26 };
	
	NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:(NSInteger)targetSize.width pixelsHigh:(NSInteger)targetSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:0 bytesPerRow:0 bitsPerPixel:0];
	
	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
	
	[NSGraphicsContext setCurrentContext:context];
	
	[testImage drawInRect:CGRectZero fromRect:NSZeroRect operation:NSCompositeCopy fraction:1. respectFlipped:YES hints:nil];
	
	[context flushGraphics];
	
	NSUInteger testPixel[4];
	
	[bitmapImageRep getPixel:&testPixel[0] atX:24 y:10];
	
	NSUInteger red = testPixel[0];
	NSUInteger green = testPixel[1];
	NSUInteger blue = testPixel[2];
	NSUInteger alpha = testPixel[3];
	
	// Should be a red pixel here if we used the @1x asset
	expect(red).to.equal(255);
	expect(green).to.equal(0);
	expect(blue).to.equal(0);
	expect(alpha).to.equal(255);
	
	expectBlueBorder(bitmapImageRep, targetSize);
});

it(@"should use @2x asset in @2x context", ^{
	CGSize targetSize = { .width = 100, .height = 52 };
	
	NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:(NSInteger)targetSize.width pixelsHigh:(NSInteger)targetSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:0 bytesPerRow:0 bitsPerPixel:0];
	
	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
		
	[NSGraphicsContext setCurrentContext:context];
	
	[testImage drawInRect:NSZeroRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1. respectFlipped:YES hints:nil];
	
	[context flushGraphics];
	
	NSUInteger testPixel[4];
		
	[bitmapImageRep getPixel:&testPixel[0] atX:24 y:10];
	
	NSUInteger red = testPixel[0];
	NSUInteger green = testPixel[1];
	NSUInteger blue = testPixel[2];
	NSUInteger alpha = testPixel[3];
	
	// Should be a green pixel here if we used the @1x asset
	expect(red).to.equal(0);
	expect(green).to.equal(255);
	expect(blue).to.equal(0);
	expect(alpha).to.equal(255);
	
	expectBlueBorder(bitmapImageRep, targetSize);
});

SpecEnd

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

beforeEach(^{
	NSURL *testImageURL = [[NSBundle bundleForClass:self.class] URLForResource:@"<RBLResizableImageSpec>_testimage" withExtension:@"tiff"];
	
	expect(testImageURL).toNot.beNil();
	
	testImage = [[RBLResizableImage alloc] initByReferencingURL:testImageURL];

	expect(testImage).toNot.beNil();
});

it(@"should use @1x asset in @1x context", ^{
	CGSize targetSize = { .width = 50, .height = 26 };
	
	NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:(NSInteger)targetSize.width pixelsHigh:(NSInteger)targetSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:0 bytesPerRow:0 bitsPerPixel:0];
	
	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
	
	[NSGraphicsContext setCurrentContext:context];
	
	[testImage drawInRect:CGRectZero fromRect:NSZeroRect operation:NSCompositeCopy fraction:1. respectFlipped:YES hints:nil];
	
	[context flushGraphics];
	
	NSUInteger testPixel[4];
	
	[[bitmapImageRep TIFFRepresentation] writeToFile:[@"~/Desktop/test.tiff" stringByExpandingTildeInPath] atomically:YES];

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
});

it(@"should use @2x asset in @2x context", ^{
	CGSize targetSize = { .width = 100, .height = 52 };
	
	NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:(NSInteger)targetSize.width pixelsHigh:(NSInteger)targetSize.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:0 bytesPerRow:0 bitsPerPixel:0];
	
	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
		
	[NSGraphicsContext setCurrentContext:context];
	
	[testImage drawInRect:NSZeroRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1. respectFlipped:YES hints:nil];
	
	[context flushGraphics];
	
	NSUInteger testPixel[4];
	
	[[bitmapImageRep TIFFRepresentation] writeToFile:[@"~/Desktop/test1.tiff" stringByExpandingTildeInPath] atomically:YES];
	
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
});

SpecEnd

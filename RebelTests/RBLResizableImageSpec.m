//
//  RBLResizableImageSpec.m
//  Rebel
//
//  Created by Alan Rogers on 16/04/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RBLResizableImage.h"

SpecBegin(RBLResizableImage)

it(@"should use @2x assets correctly", ^{
	NSURL *testImageURL = [[NSBundle bundleForClass:self.class] URLForResource:@"<RBLResizableImageSpec>_testimage" withExtension:@"tiff"];
	
	expect(testImageURL).toNot.beNil();
	NSEdgeInsets insets = NSEdgeInsetsMake(0, 5, 0, 5);
	
	RBLResizableImage *testImage = [[[RBLResizableImage alloc] initByReferencingURL:testImageURL] rbl_resizableImageWithCapInsets:insets];
	
	expect(testImage).toNot.beNil();
	
	NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:25 pixelsHigh:26 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bitmapFormat:0 bytesPerRow:0 bitsPerPixel:0];
	
	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
	
	[NSGraphicsContext setCurrentContext:context];
	
	[testImage drawInRect:(CGRect){ .origin = CGPointZero, .size = { .width = 25, .height = 26 } } fromRect:NSZeroRect operation:NSCompositeCopy fraction:1. respectFlipped:YES hints:nil];
	
	[context flushGraphics];
	
	[[bitmapImageRep TIFFRepresentation] writeToFile:[@"~/Desktop/test.tiff" stringByExpandingTildeInPath] atomically:YES];

});

SpecEnd

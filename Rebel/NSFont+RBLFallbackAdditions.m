//
//  NSFont+RBLFallbackAdditions.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-12-09.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSFont+RBLFallbackAdditions.h"

@implementation NSFont (RBLFallbackAdditions)

+ (NSFont *)rbl_fontWithName:(NSString *)fontName size:(CGFloat)fontSize fallbackNames:(NSArray *)fallbackNames {
	NSMutableArray *fallbackDescriptors = [NSMutableArray arrayWithCapacity:fallbackNames.count];
	for (NSString *fallbackName in fallbackNames) {
		[fallbackDescriptors addObject:[NSFontDescriptor fontDescriptorWithName:fallbackName size:fontSize]];
	}

	NSMutableArray *remainingFontNames = [fallbackNames mutableCopy];
	NSAssert(fallbackDescriptors.count == remainingFontNames.count, @"Should have the same number of fallback font descriptors (%lu) as names to try (%lu)", (unsigned long)fallbackDescriptors.count, (unsigned long)remainingFontNames.count);

	while (YES) {
		NSDictionary *attributes = @{ NSFontNameAttribute: fontName, NSFontCascadeListAttribute: fallbackDescriptors };

		NSFont *font = [NSFont fontWithDescriptor:[NSFontDescriptor fontDescriptorWithFontAttributes:attributes] size:fontSize];
		if (font != nil) return font;

		if (remainingFontNames.count == 0) break;

		// Try the next font in the list.
		fontName = remainingFontNames[0];
		[remainingFontNames removeObjectAtIndex:0];
		[fallbackDescriptors removeObjectAtIndex:0];
	}

	return nil;
}

@end

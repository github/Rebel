//
//  RBLShadowedTextFieldCell.m
//  Rebel
//
//  Created by Danny Greg on 18/02/2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RBLShadowedTextFieldCell.h"

#import "NSColor+RBLCGColorAdditions.h"

NSBackgroundStyle const RBLShadowedTextFieldAllBackgroundStyles = 0xFFFFFFFF;

@interface RBLShadowedTextFieldCell ()

// Maps keys of backgroundStyles to values of shadows.
@property (nonatomic, strong) NSMutableDictionary *backgroundStylesToShadows;

@end

@implementation RBLShadowedTextFieldCell

#pragma mark Lifecycle

static void CommonInit(RBLShadowedTextFieldCell *self) {
	self.backgroundStylesToShadows = [NSMutableDictionary dictionary];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	
	CommonInit(self);
	
	return self;
}

- (instancetype)initTextCell:(NSString *)aString {
	self = [super initTextCell:aString];
	if (self == nil) return nil;
	
	CommonInit(self);
	
	return self;
}

#pragma mark Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[NSGraphicsContext saveGraphicsState];
	NSShadow *shadow = self.backgroundStylesToShadows[@(self.backgroundStyle)];
	if (shadow == nil) {
		shadow = self.backgroundStylesToShadows[@(RBLShadowedTextFieldAllBackgroundStyles)];
	}
	
	if (shadow != nil) {
		CGContextSetShadowWithColor(NSGraphicsContext.currentContext.graphicsPort, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.rbl_CGColor);
	}
	
	[super drawWithFrame:cellFrame inView:controlView];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj {
	NSTextView *superTextView = (NSTextView *)[super setUpFieldEditorAttributes:textObj];
	superTextView.font = self.font;
	NSShadow *shadow = self.backgroundStylesToShadows[@(self.backgroundStyle)];
	if (shadow == nil) {
		shadow = self.backgroundStylesToShadows[@(RBLShadowedTextFieldAllBackgroundStyles)];
	}
	
	double delayInSeconds = 0.01;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSTextStorage *storage = superTextView.textStorage;
		[storage addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, storage.length)];
	});
	
	return superTextView;
}

#pragma mark API

- (void)setShadow:(NSShadow *)shadow forBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
	if (shadow == nil) {
		[self.backgroundStylesToShadows removeObjectForKey:@(backgroundStyle)];
		return;
	}
	
	self.backgroundStylesToShadows[@(backgroundStyle)] = shadow;
}

@end
